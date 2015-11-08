include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")
include("MDL_principle.jl")

f = open("data/housing.data")

x = readlines(f)
data = Array(Any,506,14)
for i = 1 : 506
         str = x[i]
         println(str)
         str_element = split(str)
         #println(str_element)
         for j = 1 : 14
                 if j == 14
                         last_one = str_element[14]
                         data[i,14] = float(split(last_one,"\n")[1])
                 elseif (j in [4,9] )
                         data[i,j] = round(Int64,float(str_element[j]))
                 else
                         data[i,j] = float(str_element[j])
                 end
         end
end

close(f)

discrete_index = [4,9]
continuous_index = [1,2,3,5,6,7,8,10,11,12,13,14]


#data_integer = Array(Int64,size(data))
#for i = 1 : 14
#      if i in continuous_index
#                data_integer[:,i] = equal_width_disc(data[:,i],5)
#      else
#                data_integer[:,i] = data[:,i]
#     end
#end
#times = 1000
#X = K2(data_integer,3,times)


#graph = [1,(1,14),4,(14,4,3),(3,10),(3,2),(10,2,3,8),(3,8,5),(8,7),(10,3,2,9),(14,1,13),(14,6),(10,12),(9,3,2,11)];
graph = [5,(5,2),(5,8),(5,2,3),(3,5,2,9),(5,2,7),(9,3,2,10),(9,3,10,11),(7,13),1,(10,12),(13,14),4,(14,1,6)];
discrete_index = [4,9]
continuous_index = [1,2,3,5,6,7,8,10,11,12,13,14]
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
