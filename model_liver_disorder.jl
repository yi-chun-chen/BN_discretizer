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
K2_w_discretization(data,2,[1,2,3,4,5,6],2,5,false)
