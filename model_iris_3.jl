include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")

f = readcsv("data/iris.csv")
f = f[1:750]
f = reshape(f,5,150)
f = f'

data = Array(Any,150,5)

continuous_index = [1,2,3,4]
discrete_index = [5]

for i = 1 : 150
    for j = 1 : 5
        if j in discrete_index
            data[i,j] = round(Int64,f[i,j])
        else
            data[i,j] = f[i,j]
        end
    end

end



graph = [(5,1),(5,2),(5,3),(5,4)]

Order = graph_to_reverse_conti_order(graph,continuous_index)
cut_time = 5

log_li_my_wo = 0; log_li_MDL = 0
times_for_sampling = 500
like_store_size_my = zeros(Float64,10)
like_store_size_MDL = zeros(Float64,10)

for run_size = 1 : 10
    println("size = ", run_size * 15, "====================================")
    N_small = 20 + run_size * 5

    for sample_t = 1 : times_for_sampling

        if sample_t%10 == 0; println("+++++++++++++++++++++",(run_size,sample_t),"++++++++++++++++++++++");end
        (train_data,test_data) = small_big_data(N_small,data)

        my_wo_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time,false)[2]
        MDL_disc_edge = MDL_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time)[2]
        reorder_my = sort_disc_by_vorder(Order,my_wo_disc_edge)
        reorder_MDL = sort_disc_by_vorder(Order,MDL_disc_edge)

        like_store_size_my[run_size] += likelihood_conti(graph,train_data,continuous_index,reorder_my,test_data,1)
        like_store_size_MDL[run_size] += likelihood_conti(graph,train_data,continuous_index,reorder_MDL,test_data,1)

    end

    like_store_size_my[run_size] = like_store_size_my[run_size] / (times_for_sampling * (150 - N_small))
    like_store_size_MDL[run_size] = like_store_size_MDL[run_size] / (times_for_sampling * (150 - N_small))

end
