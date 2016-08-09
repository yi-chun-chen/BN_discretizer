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

#graph = [8,(8,1),(1,11),(1,4),(1,2),(8,7),(1,14),(8,4,1,9),(1,3),(1,8,13),(14,1,6),(1,4,5),(1,12),(8,6,10)]
#Order = graph_to_reverse_conti_order(graph,continuous_index)
#cut_time = 10

#n_fold = 10
#data_group = cross_vali_data(n_fold,data)

#log_li_my_w = 0; log_li_my_wo = 0; log_li_MDL = 0
#for fold = 1 : n_fold
    #println("fold = ", fold,"==============================")
    #train_data = 0; test_data = 0
    #if fold == 1
    #    test_data = data_group[fold]
    #    train_data = data_group[2]
    #    for j = 3 : n_fold
    #        train_data = [train_data;data_group[j]]
    #    end
    #else
    #    test_data = data_group[fold]
    #    train_data = data_group[1]
    #    for j = 2 : n_fold
    #        if j != fold
    #            train_data = [train_data;data_group[j]]
    #        end
    #    end
    #end

    #my_w_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time)[2]
    #my_wo_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time,false)[2]
    #MDL_disc_edge = MDL_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time)[2]
    #reorder_my_w_edge = sort_disc_by_vorder(Order,my_w_disc_edge)
    #reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)
    #reorder_MDL_edge = sort_disc_by_vorder(Order,MDL_disc_edge)
    #Li_my_w = likelihood_conti(graph,train_data,continuous_index,reorder_my_w_edge,test_data,1)
    #Li_my_wo = likelihood_conti(graph,train_data,continuous_index,reorder_my_wo_edge,test_data,1)
    #Li_MDL = likelihood_conti(graph,train_data,continuous_index,reorder_MDL_edge,test_data,1)
    #log_li_my_w += Li_my_w
    #log_li_my_wo += Li_my_wo
    #log_li_MDL += Li_MDL
    #println(log_li_my_w,log_li_my_wo,log_li_MDL)

#end

#println(log_li_my_w,log_li_my_wo,log_li_MDL)

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

graph_1 = [8,(8,1),(1,11),(1,4),(1,2),(8,7),(1,14),(8,4,1,9),(1,3),(1,8,13),(14,1,6),(1,4,5),(1,12),(8,6,10)];

my_wo = Array(Any,13)
my_wo[1] = [11.03,12.745,13.54,14.83]
my_wo[2] = [0.74,1.42,2.235,5.8]
my_wo[3] = [1.36,2.03,2.605,3.07,3.23]
my_wo[4] = [10.6,17.9,23.25,30.0]
my_wo[5] = [70.0,88.5,135.0,162.0]
my_wo[6] = [0.98,2.105,2.58,3.01,3.88]
my_wo[7] = [0.34,0.975,1.885,2.31,3.355,5.08]
my_wo[8] = [0.13,0.395,0.66]
my_wo[9] = [0.41,1.185,1.655,3.58]
my_wo[10] = [1.28,3.46,4.85,7.4,13.0]
my_wo[11] = [0.48,0.785,1.005,1.295,1.71]
my_wo[12] = [1.27,2.475,4.0]
my_wo[13] = [278.0,476.0,716.0,900.5,1680.0]

MDL = Array(Any,13)
MDL[1] = [11.03,12.78,14.83]
MDL[2] = [0.74,1.42,2.235,5.8]
MDL[3] = [1.36,3.23]
MDL[4] = [10.6,17.9,30.0]
MDL[5] = [70.0,162.0]
MDL[6] = [0.98,3.88]
MDL[7] = [0.34,5.08]
MDL[8] = [0.13,0.395,0.66]
MDL[9] = [0.41,3.58]
MDL[10] = [1.28,3.46,7.55,13.0]
MDL[11] = [0.48,0.785,1.71]
MDL[12] = [1.27,2.115,2.505,4.0]
MDL[13] = [278.0,1680.0]

Y1 = sample_from_discetization(graph_1,data,continuous_index,my_wo,2000)
Y2 = sample_from_discetization(graph_1,data,continuous_index,MDL,2000)

writecsv("wine_exp1_ourmethod.dat", Y1)
writecsv("wine_exp1_MDLmethod.dat", Y2)
writecsv("win_raw.dat", data)

#########################
### Data Generating 2 ###
#########################

graph_2 = [3,4,(3,4,10),(3,12),(10,12,4,3,9),(12,9,14),(14,10,4,7),(14,3,7,9,2),(12,10,13),(13,2,12,1),(7,1,8),(1,13,4,9,5),(1,9,6),(1,11)];

my_wo_2 = Array(Any,13)
my_wo_2[1] = [11.03,12.745,14.83]
my_wo_2[2] = [0.74,2.235,5.8]
my_wo_2[3] = [1.36,1.53,1.85,3.23]
my_wo_2[4] = [10.6,17.9,30.0]
my_wo_2[5] = [70.0,88.5,133.0,162.0]
my_wo_2[6] = [0.98,2.58,3.88]
my_wo_2[7] = [0.34,0.975,2.31,2.715,4.505,5.08]
my_wo_2[8] = [0.13,0.66]
my_wo_2[9] = [0.41,0.485,1.325,1.645,3.43,3.58]
my_wo_2[10] = [1.28,3.46,4.85,7.4,13.0]
my_wo_2[11] = [0.48,0.855,1.71]
my_wo_2[12] = [1.27,2.005,2.19,4.0]
my_wo_2[13] = [278.0,368.5,953.5,1680.0]

Y3 = sample_from_discetization(graph_2,data,continuous_index,my_wo_2,2000)

writecsv("wine_exp2_ourmethod.dat", Y3)
