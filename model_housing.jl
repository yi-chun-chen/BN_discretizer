include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")

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

#graph = [2,(2,3),(3,2,14),(3,2,7),(7,14,13),(3,2,9),4,(14,4,6),(3,7,8),(7,14,12),(3,5),(3,10),(12,1),(3,11)];
#X = K2_w_discretization_compare(data,2,[1,2,3,5,6,7,8,10,11,12,13,14],10,5)
#disc_edge = BN_discretizer_iteration_converge(data,graph,[4,9],[1,2,3,5,6,7,8,10,11,12,13,14],10);

graph = [2,(2,3),(3,2,14),(3,2,7),(7,14,13),(3,2,9),4,(14,4,6),(3,7,8),(7,14,12),(3,5),(3,10),(12,1),(3,11)];
disc_edge = BN_discretizer_iteration_converge(data,graph,[4,9],[1,2,3,5,6,7,8,10,11,12,13,14],10);
disc_edge = disc_edge[2]
