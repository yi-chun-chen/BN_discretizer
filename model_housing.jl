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

graph = [8,(8,5),(5,6),(8,2),(5,2,3),(8,7),(3,8,2,10),4,(10,12),(6,10,14),(14,13),(3,8,10,2,11),1,(10,11,3,2,9)];
discrete_index = [4,9]
continuous_index = [14,13,12,11,10,8,7,6,5,3,2,1]
cut_time = 10
my_disc_edge_w = BN_discretizer_iteration_converge(data,graph,discrete_index,continuous_index,cut_time)[2]
println("my_w_done =========================== ")
my_disc_edge_wo = BN_discretizer_iteration_converge(data,graph,discrete_index,continuous_index,cut_time,false)[2]
println("my_wo_done =========================== ")
MDL_disc =  MDL_discretizer_iteration_converge(data,graph,discrete_index,continuous_index,cut_time)[2]
println("MDL_done =========================== ")

g = open("housing_result.txt","w")
println(g,my_disc_edge_w)
println(g,my_disc_edge_wo)
println(g,MDL_disc)
close(g)
