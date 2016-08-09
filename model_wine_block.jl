include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")
using Discretizers

f = open("data/wine.data")

x = readlines(f)
discrete_index = [1]
continuous_index = [2,3,4,5,6,7,8,9,10,11,12,13,14]
data = Array(Any,178,14)
for i = 1 : 178
         str = x[i]
         println(str)
         str_element = split(str,",")
         for j = 1 : 14
                 if j == 14
                         last_one = str_element[14]
                         data[i,14] = float(split(last_one,"\n")[1])
                 elseif j in discrete_index
                         data[i,j] = round(Int64,float(str_element[j]))
                 else
                         data[i,j] = float(str_element[j])
                 end
         end
end

close(f)

#
#data_integer = Array(Int64,size(data))
#for i = 1 : 14
#      if i in continuous_index
#                data_integer[:,i] = equal_width_disc(data[:,i],3)
#      else
#                 data_integer[:,i] = data[:,i]
#      end
#end

#times = 1000
#X = K2(data_integer,2,times)

graph =  [8,(8,1),(1,11),(1,4),(1,2),(8,7),(1,14),(8,4,1,9),(1,3),(1,8,13),(14,1,6),(1,4,5),(1,12),(8,6,10)];
Order = graph_to_reverse_conti_order(graph,continuous_index)
cut_time = 10

n_fold = 10
data_group = cross_vali_data(n_fold,data)

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

    for conti_v = 1 : 13

        the_conti_index = continuous_index[conti_v]
        #block_disc_edge[conti_v] = equal_width_edge_no_sort(train_data[:,the_conti_index],6)
        block_disc_edge[conti_v] = binedges(DiscretizeBayesianBlocks(), convert(Vector{Float64}, train_data[:,the_conti_index]))

    end

    Li_block_w = likelihood_conti(graph,train_data,continuous_index,block_disc_edge,test_data,1)

    log_li_blocks += Li_block_w

    println((log_li_my_wo,log_li_blocks,fold))

end
