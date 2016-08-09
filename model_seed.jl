include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")
include("MDL_principle.jl")

f = open("data/seeds_dataset.data")

discrete_index = [8]
continuous_index = [1,2,3,4,5,6,7]


x = readlines(f)
data = Array(Any,210,8)
for i = 1 : 210
    str = x[i]
    #println(str)
    str_element = split(str,"\t")
    #println(str_element)
    for j = 1 : 8
        if j in discrete_index
            data[i,j] = round(Int64,float(str_element[j]))
        else
            data[i,j] = float(str_element[j])
        end
    end
end

close(f)

# Learning the graph structure by prediscretization

#cut_time = 7
#u = 12; times = 5;
#A = K2_w_discretization(data,u,continuous_index,times,cut_time,false)

data_integer = Array(Int64,size(data))
for i = 1 : 8
      if i in continuous_index
                data_integer[:,i] = equal_width_disc(data[:,i],3)
      else
                data_integer[:,i] = data[:,i]
     end
end
times = 500
X = K2(data_integer,8,times)

#graph = [1,(1,2),(2,5),(2,8),(2,1,4),(2,8,4,7),(5,2,3),(8,1,6)];

#cut_time = 10
#Order = graph_to_reverse_conti_order(graph,continuous_index)

#n_fold = 10
#data_group = cross_vali_data(n_fold,data)

#log_li_my_w = 0; log_li_my_wo = 0; log_li_MDL = 0
#for fold = 1 : n_fold
#    println("fold = ", fold,"==============================")
#    train_data = 0; test_data = 0
#    if fold == 1
#        test_data = data_group[fold]
#        train_data = data_group[2]
#        for j = 3 : n_fold
#            train_data = [train_data;data_group[j]]
#        end
#    else
#        test_data = data_group[fold]
#        train_data = data_group[1]
#        for j = 2 : n_fold
#            if j != fold
#                train_data = [train_data;data_group[j]]
#            end
#        end
#    end

#    my_wo_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time,false)[2]
#    MDL_disc_edge = MDL_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time)[2]
#    reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)
#    reorder_MDL_edge = sort_disc_by_vorder(Order,MDL_disc_edge)

#    Li_my_wo = likelihood_conti(graph,train_data,continuous_index,reorder_my_wo_edge,test_data,1)
#    Li_MDL = likelihood_conti(graph,train_data,continuous_index,reorder_MDL_edge,test_data,1)

#    log_li_my_wo += Li_my_wo
#    log_li_MDL += Li_MDL
#    println(log_li_my_wo,log_li_MDL)

#end

#println(log_li_my_wo,log_li_MDL)

#my_wo_disc_edge = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time,false)[2]
#MDL_disc_edge = MDL_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
#reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)
#reorder_MDL_edge = sort_disc_by_vorder(Order,MDL_disc_edge)

##############
### Result ###
##############

# graph = [1,(1,2),(2,5),(2,8),(2,1,4),(2,8,4,7),(5,2,3),(8,1,6)];
# Likelihood = (-493.7992612007103,-1200.67045454443)
# my_discretization =

#[10.59,13.64,14.475,16.58,18.065,21.18]
#[12.41,13.985,14.42,15.42,16.015,17.25]
#[0.8081,0.86915,0.91305,0.9183]
#[4.899,5.4995,5.9525,6.675]
#[2.63,3.0825,3.4,3.588,4.033]
#[0.7651,3.178,8.456]
#[4.519,5.5755,6.55]

# MDL_discretization =
# [10.59,21.18]
# [12.41,17.25]
# [0.8081,0.9183]
# [4.899,6.675]
# [2.63,4.033]
# [0.7651,3.2285,8.456]
# [4.519,5.5755,6.55]
