include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")

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

data_2 = Array(Any,size(data))
for j = 1 : 14
    if j in continuous_index
        min_v = minimum(data[:,j])
        max_v = maximum(data[:,j])
        for i = 1 : 178
            data_2[i,j] = (data[i,j] - min_v)/max_v
        end
    else
        for i = 1 : 178
            data_2[i,j] = data[i,j]
        end
    end
end


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

graph = [8,(8,1),(1,11),(1,4),(1,2),(8,7),(1,14),(8,4,1,9),(1,3),(1,8,13),(14,1,6),(1,4,5),(1,12),(8,6,10)];

#graph = [8,(8,1),(1,11),(1,4),(1,2),(8,7),(1,14),(8,4,1,9),(1,3),(1,8,13),(14,1,6),(1,4,5),(1,12),(8,6,10)]
Order = graph_to_reverse_conti_order(graph,continuous_index)
cut_time = 10

#wo_scale = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time,false)[2]
#w_scale = BN_discretizer_iteration_converge(data_2,graph,discrete_index,Order,cut_time,false)[2]



n_fold = 10
data_group = cross_vali_data(n_fold,data_2)

log_li_my_w = 0; log_li_my_wo = 0; log_li_MDL = 0
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

    my_w_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time)[2]
    my_wo_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time,false)[2]
    MDL_disc_edge = MDL_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time)[2]
    reorder_my_w_edge = sort_disc_by_vorder(Order,my_w_disc_edge)
    reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)
    reorder_MDL_edge = sort_disc_by_vorder(Order,MDL_disc_edge)
    Li_my_w = likelihood_conti(graph,train_data,continuous_index,reorder_my_w_edge,test_data,1)
    Li_my_wo = likelihood_conti(graph,train_data,continuous_index,reorder_my_wo_edge,test_data,1)
    Li_MDL = likelihood_conti(graph,train_data,continuous_index,reorder_MDL_edge,test_data,1)
    log_li_my_w += Li_my_w
    log_li_my_wo += Li_my_wo
    log_li_MDL += Li_MDL
    println(log_li_my_w,log_li_my_wo,log_li_MDL)

end

println(log_li_my_w,log_li_my_wo,log_li_MDL)

#my_disc_edge_w = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
#my_disc_edge_wo = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time,false)[2]
#MDL_disc =  MDL_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]

#reorder_my_w_edge = sort_disc_by_vorder(Order,my_disc_edge)
#reorder_my_wo_edge = sort_disc_by_vorder(Order,my_disc_edge_wo)
#reorder_MDL_edge = sort_disc_by_vorder(Order,MDL_disc)

#u = 13; times = 20;
#A = K2_w_discretization(data,u,continuous_index,times,cut_time,false)

#########################
### Data Generating 1 ###
#########################


