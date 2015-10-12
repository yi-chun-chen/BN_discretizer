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
X = K2_w_discretization(data,2,[1,2,3,5,6,7,8,10,11,12,13,14],1,5)
