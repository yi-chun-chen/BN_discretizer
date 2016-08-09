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

#cut_time = 7
#u = 7; times = 45;
#A = K2_w_discretization(data,u,continuous_index,times,cut_time,false)

#data_integer = Array(Int64,size(data))
#for i = 1 : 7
#      if i in continuous_index
#                data_integer[:,i] = equal_width_disc(data[:,i],5)
#      else
#                 data_integer[:,i] = data[:,i]
#      end
#end
#
#times = 1000
#X = K2(data_integer,6,times)

#graph = [2,(2,3),(3,5),(5,1),(1,5,3,7),(3,4),(4,6),8]
#Order = graph_to_reverse_conti_order(graph,continuous_index)
#cut_time = 8
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
#
#    my_w_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time)[2]
#    my_wo_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time,false)[2]
#    MDL_disc_edge = MDL_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time)[2]
#    reorder_my_w_edge = sort_disc_by_vorder(Order,my_w_disc_edge)
#    reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)
#    reorder_MDL_edge = sort_disc_by_vorder(Order,MDL_disc_edge)
#    Li_my_w = likelihood_conti(graph,train_data,continuous_index,reorder_my_w_edge,test_data,1)
#    Li_my_wo = likelihood_conti(graph,train_data,continuous_index,reorder_my_wo_edge,test_data,1)
#    Li_MDL = likelihood_conti(graph,train_data,continuous_index,reorder_MDL_edge,test_data,1)
#    log_li_my_w += Li_my_w
#    log_li_my_wo += Li_my_wo
#    log_li_MDL += Li_MDL
#    println(log_li_my_w,log_li_my_wo,log_li_MDL)
#end

#println(log_li_my_w,log_li_my_wo,log_li_MDL)

#my_w_disc_edge = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
#my_wo_disc_edge = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time,false)[2]
#MDL_disc_edge = MDL_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
#reorder_my_w_edge = sort_disc_by_vorder(Order,my_w_disc_edge)
#reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)
#reorder_MDL_edge = sort_disc_by_vorder(Order,MDL_disc_edge)

#########################
### Data Generating 1 ###
#########################

graph = [2,(2,3),(3,5),(5,1),(1,5,3,7),(3,4),(4,6),8]

my_disc = Array(Any,5)
my_disc[1] = [9.0,15.25,17.65,20.9,25.65,28.9,46.6]
my_disc[2] = [68.0,70.5,93.5,109.0,159.5,259.0,284.5,455.0]
my_disc[3] = [46.0,71.5,99.0,127.0,230.0]
my_disc[4] = [1613.0,2115.0,2480.5,2959.5,3657.5,5140.0]
my_disc[5] = [8.0,12.35,13.75,16.05,22.85,24.8]

MDL_disc = Array(Any,5)
MDL_disc[1] = [9.0,46.6]
MDL_disc[2] = [68.0,455.0]
MDL_disc[3] = [46.0,230.0]
MDL_disc[4] = [1613.0,5140.0]
MDL_disc[5] = [8.0,24.8]

Y1 = sample_from_discetization(graph,data,continuous_index,my_disc,2000)
Y2 = sample_from_discetization(graph,data,continuous_index,MDL_disc,2000)

writecsv("autoMPG_exp1_ourmethod.dat", Y1)
writecsv("autoMPG_exp2_MDLmethod.dat", Y2)
writecsv("autoMPG_raw.dat", data)



#########################
### Data Generating 2 ###
#########################

#graph = [2,(2,5),(2,5,1),(2,5,8),(1,8,7),(2,8,3),(2,5,3,8,4),(4,2,5,6)]

#my_k2_disc = Array(Any,5)
#my_k2_disc[1] = [9.0,17.55,23.95,46.6]
#my_k2_disc[2] = [68.0,134.5,159.5,169.5,259.0,264.5,455.0]
#my_k2_disc[3] = [46.0,115.5,230.0]
#my_k2_disc[4] = [1613.0,2764.5,3030.0,3923.5,5140.0]
#my_k2_disc[5] = [8.0,14.05,24.8]

#Y1 = sample_from_discetization(graph,data,continuous_index,my_k2_disc,2000)

#writetable("autoMPG_exp2_ourmethod.dat", Y1, separator = ',', header = false)

