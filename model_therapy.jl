include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")

f = open("data/ThoraricSurgery.date.txt")

x = readlines(f)

tf_set = [5,6,7,8,9,11,12,13,14,15]
eleme = 0
data = Array(Any,470,17)
for i = 1 : 470
    str = x[i]
    str_element = split(str,",")
    #eleme = str_element
    for j = 1 : 17
        if j == 17
            last_one = str_element[17]
            d = split(last_one,"\r")[1]
            if d == "F"
                data[i,17] = 0
            else
                data[i,17] = 1
            end
        elseif j in tf_set

            if str_element[j] == "F"
                data[i,j] = 0
            else
                data[i,j] = 1
            end
        elseif j == 1
            d = split(str_element[1],"N")[2]
            data[i,j] = round(Int64,float(d))
        elseif j == 4
            d = split(str_element[4],"Z")[2]
            data[i,j] = round(Int64,float(d))
        elseif j == 10
            d = split(str_element[10],"C")[2]
            data[i,j] = round(Int64,float(d))
        else
            data[i,j] = float(str_element[j])
        end
    end
end

close(f)

discrete_index = [1,4,5,6,7,8,9,10,11,12,13,14,15,17]
continuous_index = [2,3,16]

#data_integer = Array(Int64,size(data))
#for i = 1 : 17
#      if i in continuous_index
#                data_integer[:,i] = equal_width_disc(data[:,i],2)
#      else
#                 data_integer[:,i] = data[:,i]
#      end
#end
#
#times = 100
#X = K2(data_integer,17,times)

graph = [15,13,4,3,16,(4,9),(3,4,13,7),(16,2),(2,11),(11,7,17),(3,5),(17,10),1,(5,13,9,7,6),12,(4,5,6,3,9,8),(8,15,16,5,7,14)];
Order = graph_to_reverse_conti_order(graph,continuous_index)
cut_time = 10

X = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]