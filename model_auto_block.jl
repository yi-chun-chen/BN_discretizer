using Discretizers

include("disc_BN_MODL.jl")
include("MDL_principle.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")



f = readcsv("data/auto-mpg_2_m.csv")

data = Array(Any,392,8)

discrete_index = [2,7,8]
continuous_index = [1,3,4,5,6]

for i = 1 : 392
    for j = 1 : 8
        if j in discrete_index
            data[i,j] = round(Int64,f[i,j])
        else
            data[i,j] = f[i,j]
        end
    end
end


graph = [2,(2,3),(3,5),(5,1),(1,5,3,7),(3,4),(4,6),8]
Order = graph_to_reverse_conti_order(graph,continuous_index)
cut_time = 8
n_fold = 10
data_group = cross_vali_data(n_fold,data)

block_disc_edge = 0
log_li_my_w = 0; log_li_my_wo = 0; log_li_MDL = 0; log_li_blocks = 0

for fold = 1 : n_fold
    println("fold = ", fold,"==============================")
    train_data = 0; test_data = 0
    if fold == 1
        test_data = data_group[fold]
        train_data = data_group[2]
        for j = 3 : n_fold
            train_data = [train_data;data_group[j]]
        end
    else
        test_data = data_group[fold]
        train_data = data_group[1]
        for j = 2 : n_fold
            if j != fold
                train_data = [train_data;data_group[j]]
            end
        end
    end


    my_wo_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time,false)[2]
    reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)

    Li_my_wo = likelihood_conti(graph,train_data,continuous_index,reorder_my_wo_edge,test_data,1)
    log_li_my_wo += Li_my_wo

    #println("usssss")

    ############

    block_disc_edge = Array(Any,14)

    for conti_v = 1 : 5

        the_conti_index = continuous_index[conti_v]
        #block_disc_edge[conti_v] = equal_width_edge_no_sort(train_data[:,the_conti_index],6)
        block_disc_edge[conti_v] = binedges(DiscretizeBayesianBlocks(), convert(Vector{Float64}, train_data[:,the_conti_index]))

    end

    Li_block_w = likelihood_conti(graph,train_data,continuous_index,block_disc_edge,test_data,1)

    log_li_blocks += Li_block_w

    println((log_li_my_wo,log_li_blocks,fold))


end

#println(log_li_my_w,log_li_my_wo,log_li_MDL)

#graph = [2,(2,3),(3,5),(5,1),(1,5,3,7),(3,4),(4,6),8]
#Order = graph_to_reverse_conti_order(graph,continuous_index)
#cut_time = 8

#my_w_disc_edge = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
#my_wo_disc_edge = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time,false)[2]
#MDL_disc_edge = MDL_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
#reorder_my_w_edge = sort_disc_by_vorder(Order,my_w_disc_edge)
#reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)
#reorder_MDL_edge = sort_disc_by_vorder(Order,MDL_disc_edge)

#Y1 = sample_from_discetization(graph,data,continuous_index,reorder_my_wo_edge,2000)

#writecsv("housing_exp1_ourmethod.dat", Y1)
