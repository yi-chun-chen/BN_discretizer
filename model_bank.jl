include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")
include("MDL_principle.jl")

f = open("data/bank.txt")

discrete_index = [5]
continuous_index = [1,2,3,4]

count = 0
x = readlines(f)
data = Array(Any,1372,5)
for i = 1 : 1372
    str = x[i]
    #println(str)
    str_element = split(str,",")
    #if length(str_element) == 5; count += 1; end
    #println(str_element)
    for j = 1 : 5
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
for i = 1 : 5
      if i in continuous_index
                data_integer[:,i] = equal_width_disc(data[:,i],2)
      else
                data_integer[:,i] = data[:,i]
     end
end
times = 200
X = K2(data_integer,5,times)


#graph = [4,(4,2),(2,4,1),(2,1,3),(1,4,5)]


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

# graph = [4,(4,2),(2,4,1),(2,1,3),(1,4,5)]
# Likelihood = (-346.5515534450501,-1660.7265941110622)
# my_discretization =

# [1.51115,1.514585,1.5188000000000001,1.524425,1.53393]
# [10.73,10.875,15.47,16.585,17.38]
# [0.0,1.985,4.49]
# [0.29,1.92,3.27,3.5]
# [69.81,72.255,74.865,75.41]
# [0.0,1.255,2.23,4.455,6.21]
# [5.43,7.685,9.47,12.87,16.19]
# [0.0,0.335,1.955,2.54,3.15]
# [0.0,0.085,0.17,0.255,0.34,0.425,0.51]

# MDL_discretization =
# [-7.0421,6.8248]
# [-13.37731,]
# [0.0,4.49]
# [0.29,3.5]
# [69.81,75.41]
# [0.0,6.21]
# [5.43,16.19]
# [0.0,3.15]
# [0.0,0.085,0.17,0.255,0.34,0.425,0.51]
