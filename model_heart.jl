include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")
include("MDL_principle.jl")

f = open("data/heart.data")

discrete_index = [2,3,6,7,9,11,12,13]
continuous_index = [1,4,5,8,10]


x = readlines(f)
data = Array(Any,270,13)
for i = 1 : 270
    str = x[i]
    #println(str)
    str_element = split(str)
    #println(str_element)
    for j = 1 : 13
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

#data_integer = Array(Int64,size(data))
#for i = 1 : 13
#      if i in continuous_index
#                data_integer[:,i] = equal_width_disc(data[:,i],3)
#      else
#                data_integer[:,i] = data[:,i]
#     end
#end
#times = 1000
#X = K2(data_integer,3,times)

graph = [10,(10,3),(3,9),(10,7),(10,9,11),6,(11,9,8),5,(8,1),(1,12),(9,13),(5,6,4),(13,2)];

cut_time = 10
Order = graph_to_reverse_conti_order(graph,continuous_index)

n_fold = 10
data_group = cross_vali_data(n_fold,data)

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
#
#    my_w_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time)[2]
    my_wo_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time,false)[2]
    MDL_disc_edge = MDL_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time)[2]
#    reorder_my_w_edge = sort_disc_by_vorder(Order,my_w_disc_edge)
    reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)
    reorder_MDL_edge = sort_disc_by_vorder(Order,MDL_disc_edge)
#    Li_my_w = likelihood_conti(graph,train_data,continuous_index,reorder_my_w_edge,test_data,1)
    Li_my_wo = likelihood_conti(graph,train_data,continuous_index,reorder_my_wo_edge,test_data,1)
    Li_MDL = likelihood_conti(graph,train_data,continuous_index,reorder_MDL_edge,test_data,1)
#    log_li_my_w += Li_my_w
    log_li_my_wo += Li_my_wo
    log_li_MDL += Li_MDL
    println(log_li_my_w,log_li_my_wo,log_li_MDL)

end
#
println(log_li_my_wo,log_li_MDL)

#my_w_disc_edge = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
my_wo_disc_edge = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time,false)[2]
MDL_disc_edge = MDL_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
#reorder_my_w_edge = sort_disc_by_vorder(Order,my_w_disc_edge)
reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)
reorder_MDL_edge = sort_disc_by_vorder(Order,MDL_disc_edge)

##############
### Result ###
##############

# graph = [10,(10,3),(3,9),(10,7),(10,9,11),6,(11,9,8),5,(8,1),(1,12),(9,13),(5,6,4),(13,2)];
# Likelihood = (-6968.991087138561,-7265.533974541502)
# my_discretization = ([29.0,52.5,77.0], [94.0,200.0], [126.0,490.5,564.0], [71.0,117.5,155.5,202.0],[0.0,0.05,1.95,6.2])
# MDL_discretization = ([29.0,51.5,77.0], [94.0,200.0], [126.0,564.0], [71.0,202.0], [0.0,0.85,6.2])


