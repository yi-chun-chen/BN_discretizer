include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("MDL_principle.jl")

f = open("data/auto-mpg.csv")
x = readline(f)
x = split(x,"\r")
data = Array(Float64,length(x),8)
for i = 1 : length(x)
        str = x[i]
        str_element = split(str,",")
        for j = 1 : 8
                data[i,j] = float(str_element[j])
        end
end

mpg = data[:,1]

cylind = Array(Int64,length(x))
for i = 1 : length(x)
        cylind[i] = int(data[i,2])
end

year = Array(Int64,length(x))
for i = 1 : length(x)
        year[i] = int(data[i,7])
end

origin = Array(Int64,length(x))
for i = 1 : length(x)
        origin[i] = int(data[i,8])
end

displace = equal_width_disc(data[:,3],4)
horsep = equal_width_disc(data[:,4],4)
weight = equal_width_disc(data[:,5],5)
acc = equal_width_disc(data[:,6],3)

p = sortperm(mpg)
mpg = mpg[p]
cylind = cylind[p]
displace = displace[p]
horsep = horsep[p]
weight = weight[p]
acc = acc[p]
year = year[p]
origin = origin[p]


data_matrix = [cylind displace horsep weight acc year origin]
#combi = combine_spouses_data(data_matrix)

graph = [1 2 3 (1,2,3,4) (4,5) (4,7,6)]
parent_set = [1,2,3]
child_spouse_set = [4,(5,6)]

close(f)
