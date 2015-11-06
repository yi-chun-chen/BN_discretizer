include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")

f = open("data/wine.data")

x = readlines(f)
disc_index = [1]
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
                 elseif j in disc_index
                         data[i,j] = round(Int64,float(str_element[j]))
                 else
                         data[i,j] = float(str_element[j])
                 end
         end
end

close(f)

# data_integer = Array(Int64,size(data))
# for i = 1 : 14
#        if i in continuous_index
#                  data_integer[:,i] = equal_width_disc(data[:,i],3)
#        else
#                  data_integer[:,i] = data[:,i]
#       end
# end

# times = 100
# X = K2(data_integer,13,times)


graph = [8,(8,1),(1,4),(1,14),(1,11),(14,1,6),(1,2),(1,8,13),(8,6,10),(1,3),(1,12),(8,4,1,9),(1,4,5),(8,7)];
Order = graph_to_reverse_conti_order(graph,continuous_index)
#cut_time = 8
#my_disc_edge_w = BN_discretizer_iteration_converge(data,graph,disc_index,Order,cut_time)[2]
#my_disc_edge_wo = BN_discretizer_iteration_converge(data,graph,disc_index,Order,cut_time,false)[2]
#MDL_disc =  MDL_discretizer_iteration_converge(data,graph,disc_index,Order,cut_time)[2]

MY_w = Array(Any,13)
MY_w[6] =  [0.98,2.105,2.58,3.88]
MY_w[4] =  [10.6,17.9,24.25,30.0]
MY_w[8] =  [0.13,0.395,0.66]
MY_w[11] =  [0.48,0.785,1.005,1.295,1.71]
MY_w[2] =  [0.74,1.42,2.235,5.8]
MY_w[9] =  [0.41,1.655,3.58]
MY_w[12] =  [1.27,2.19,2.49,4.0]
MY_w[1] =  [11.03,12.745,13.54,14.83]
MY_w[5] =  [70.0,88.5,135.0,162.0]
MY_w[10] =  [1.28,3.46,4.85,7.4,13.0]
MY_w[13] =  [278.0,476.0,716.0,900.5,1680.0]
MY_w[3] =   [1.36,2.03,2.63,3.07,3.23]
MY_w[7] =  [0.34,0.975,1.885,2.31,5.08]

MY_wo = Array(Any,13)
MY_wo[6] =  [0.98,2.105,2.58,3.01,3.88]
MY_wo[4] =  [10.6,17.9,23.25,30.0]
MY_wo[8] =  [0.13,0.395,0.66]
MY_wo[11] =  [0.48,0.785,1.005,1.295,1.71]
MY_wo[2] =  [0.74,1.42,2.235,5.8]
MY_wo[9] =  [0.41,1.185,1.655,3.58]
MY_wo[12] =  [1.27,2.475,4.0]
MY_wo[1] =  [11.03,12.745,13.54,14.83]
MY_wo[5] =  [70.0,88.5,135.0,162.0]
MY_wo[10] =  [1.28,3.46,4.85,7.4,13.0]
MY_wo[13] =  [278.0,476.0,716.0,900.5,1680.0]
MY_wo[3] =   [1.36,2.03,2.605,2.63,3.07,3.23]
MY_wo[7] =  [0.34,0.975,1.885,2.31,3.355,5.08]

MDL = Array(Any,13)
MDL[6] =  [0.98,3.88]
MDL[4] =  [10.6,17.9,30.0]
MDL[8] =  [0.13,0.395,0.66]
MDL[11] =  [0.48,0.785,1.71]
MDL[2] =  [0.74,1.42,2.235,5.8]
MDL[9] =  [0.41,3.58]
MDL[12] =  [1.27,2.115,2.505,4.0] ####
MDL[1] =  [11.03,12.78,14.83]
MDL[5] =  [70.0,162.0]
MDL[10] =  [1.28,3.46,7.55,13.0]
MDL[13] =  [278.0,1680.0]
MDL[3] =   [1.36,3.23]
MDL[7] =  [0.34,5.08]

Y1 = sample_from_discetization(graph,data,continuous_index,MY_w,180)
Y2 = sample_from_discetization(graph,data,continuous_index,MY_wo,180)
Y3 = sample_from_discetization(graph,data,continuous_index,MDL,180)
