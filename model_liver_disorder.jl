include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")

f = open("data/bupa.data")

x = readlines(f)
data = Array(Any,345,7)
for i = 1 : 345
         str = x[i]
         println(str)
         str_element = split(str,",")
         for j = 1 : 7
                 if j == 7
                         last_one = str_element[7]
                         data[i,7] = round(Int64,float(split(last_one,"\n")[1]))
                 #elseif j == 6
                 #        data[i,6] = round(Int64,float(str_element[j]))
                 else
                         data[i,j] = float(str_element[j])
                 end
         end
end

close(f)

discrete_index = [7]
continuous_index = [1,2,3,4,5,6]

graph = [3,(3,4),(4,7),(4,3,5),1,(3,4,6),(5,6,2)];
Order = graph_to_reverse_conti_order(graph,continuous_index)

cut_time = 5

#my_disc_edge_w = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
#my_disc_edge_wo = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time,false)[2]
#MDL_disc =  MDL_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]

MY_wo = Array(Any,6)
MY_wo[2] =  [23.0,138.0]
MY_wo[6] =  [0.0,8.5,18.0,20.0]
MY_wo[1] =  [65.0,84.0,103.0]
MY_wo[5] =  [5.0,50.5,74.5,297.0]
MY_wo[4] =  [5.0,31.5,44.0,82.0]
MY_wo[3] =  [4.0,42.5,79.0,155.0]

MY_w = Array(Any,6)
MY_w[2] =  [23.0,138.0]
MY_w[6] =  [0.0,8.5,18.0,20.0]
MY_w[1] =  [65.0,84.0,103.0]
MY_w[5] =  [5.0,50.5,297.0]
MY_w[4] =  [5.0,31.5,44.0,82.0]
MY_w[3] =  [4.0,42.5,79.0,155.0]

MDL = Array(Any,6)
MDL[2] = [23.0,138.0]
MDL[6] = [0.0,20.0]
MDL[1] = [65.0,84.0,103.0]
MDL[5] = [5.0,297.0]
MDL[4] = [5.0,82.0]
MDL[3] = [4.0,155.0]

Y1 = sample_from_discetization(graph,data,[1,2,3,4,5,6],MY_w,300)
Y2 = sample_from_discetization(graph,data,[1,2,3,4,5,6],MY_wo,300)
Y3 = sample_from_discetization(graph,data,[1,2,3,4,5,6],MDL,300)

# data_integer = Array(Int64,size(data))
# for i = 1 : 7
#        if i in continuous_index
#                  data_integer[:,i] = equal_width_disc(data[:,i],2)
#        else
#                data_integer[:,i] = data[:,i]
#       end
# end
# times = 300
# X = K2(data_integer,6,times)



#X = K2_w_discretization_compare(data,2,[1,2,3,4,5,6],50,5)
