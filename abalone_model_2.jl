include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")

f = open("data/abalone.data")

x = readlines(f)
data = Array(Float64,4177,9)
for i = 1 : 4177
        str = x[i]
        str_element = split(str,",")
        for j = 1 : 9
                if j == 1
                        if str_element[1] == "M"
                                data[i,1] = 1
                        elseif str_element[1] == "F"
                                data[i,1] = 2
                        else
                                data[i,1] = 3
                        end
                elseif j == 9
                        last_one = str_element[9]
                        data[i,9] = float(split(last_one,"\n")[1])
                else
                        data[i,j] = float(str_element[j])
                end
        end
end


close(f)

discrete_index = [1]
continuous_index = [2,3,4,5,6,7,8,9]
#data_integer = Array(Int64,size(data))
# for i = 1 : 9
#        if i in continuous_index
#                  data_integer[:,i] = equal_width_disc(data[:,i],3)
#        else
#                  data_integer[:,i] = data[:,i]
#       end
#end

#times = 500
#X = K2(data_integer,8,times)

graph = [5,4,(5,8),(5,8,7),(5,3),(5,7,6),(3,8,6,9),(3,2),(3,6,1)]
Order = graph_to_reverse_conti_order(graph,continuous_index)
cut_time = 5

my_disc_edge_w = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
