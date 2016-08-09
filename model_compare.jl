include("distrib_generator.jl")
include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")


N = 800

data = Array(Any,N,3)

for i = 1 : N

    x_1 = rand()

    if x_1 < 0.5

        data[i,1] = 1
    else
        data[i,1] = 2

    end

    x_2 = rand()

    if x_2 < 0.5
        data[i,2] = 3
    else
        data[i,2] = 4
    end

    if (data[i,1] == 1 && data[i,2] == 3)
        data[i,3] = uniform_distrib_single(2,6)
    elseif (data[i,1] == 1 && data[i,2] == 4)
        data[i,3] = uniform_distrib_single(1,3)
    elseif (data[i,1] == 2 && data[i,2] == 3)
        data[i,3] = uniform_distrib_single(4,5)
    else
        data[i,3] = uniform_distrib_single(4.5,7.5)
    end

end

continuous_index = [3]
discrete_index = [1,2]

graph = [(1,2,3)]

Order = graph_to_reverse_conti_order(graph,continuous_index)
cut_time = 1

times_for_sampling = 50
like_store_size_my = zeros(Float64,12)
like_store_size_MDL = zeros(Float64,12)
edge_store_size_my = zeros(Float64,12)
edge_store_size_MDL = zeros(Float64,12)

for run_size = 1 : 12

    N_small = 100 + run_size * 50
    println("size = ", N_small, "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")

    for sample_t = 1 : times_for_sampling

        (train_data,test_data) = small_big_data(N_small,data)
        println("sample_t = ",(N_small,sample_t),"==========================================")

        my_wo_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time,false)[2]
        MDL_disc_edge = MDL_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time)[2]
        reorder_my = sort_disc_by_vorder(Order,my_wo_disc_edge)
        reorder_MDL = sort_disc_by_vorder(Order,MDL_disc_edge)

        a += likelihood_conti(graph,train_data,continuous_index,reorder_my,test_data,1)
        b += likelihood_conti(graph,train_data,continuous_index,reorder_MDL,test_data,1)
        c += length(reorder_my[1]) - 2
        d += length(reorder_MDL[1]) - 2

        #like_store_size_my[run_size] += likelihood_conti(graph,train_data,continuous_index,reorder_my,test_data,1)
        #like_store_size_MDL[run_size] += likelihood_conti(graph,train_data,continuous_index,reorder_MDL,test_data,1)
        #edge_store_size_my[run_size] += length(reorder_my[1]) - 2
        #edge_store_size_MDL[run_size] += length(reorder_MDL[1]) - 2

    end

    like_store_size_my[run_size] = like_store_size_my[run_size] / (times_for_sampling * (N - N_small))
    like_store_size_MDL[run_size] = like_store_size_MDL[run_size] / (times_for_sampling * (N - N_small))
    edge_store_size_my[run_size] = edge_store_size_my[run_size] / times_for_sampling
    edge_store_size_MDL[run_size] = edge_store_size_MDL[run_size] / times_for_sampling

    println((like_store_size_my[run_size],like_store_size_MDL[run_size]))
    println((edge_store_size_my[run_size],edge_store_size_MDL[run_size]))

end
