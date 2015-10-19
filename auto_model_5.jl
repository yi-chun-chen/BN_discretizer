include("disc_BN_MODL.jl")
include("MDL_principle.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")

f = open("data/auto-mpg.csv")
#g = open("auto_model_density.m","w")
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
for i = 1 : length(x)
        mpg[i] = mpg[i]
end

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

displace = data[:,3]

horsep = data[:,4]
for i = 1 : 392
        horsep[i] = horsep[i]
end

weight = data[:,5]
for i = 1 : 392
        weight[i] = weight[i]
end

acc = data[:,6]
data_matrix = [cylind displace horsep weight acc year origin]
data = Array(Any,392,7)
for i = 1 : 392
        data[i,1] = cylind[i]
        data[i,2] = displace[i]
        data[i,3] = horsep[i]
        data[i,4] = mpg[i]
        data[i,5] = weight[i]
        data[i,6] = acc[i]
        data[i,7] = year[i]
end

graph = [1 2 3 (1,2,3,4) (4,5) (4,7,6)]
target = 3
parent_set = graph_to_markov(graph,target)[1]
child_spouse_set = graph_to_markov(graph,target)[2]

discrete_index = [1,7]
continuous_index = [6,5,4,3,2]
times = 5

#X = BN_discretizer_iteration(data,graph,discrete_index,continuous_index,times)

graph = [1,(1,4),(1,4,2),(2,1,6),(1,4,5),(4,2,7),(2,1,3)];
#X = K2_w_discretization_compare(data,2,[2,3,4,5,6],20,5)
#MY_disc_edge = BN_discretizer_iteration_converge(data,graph,[1,7],[6,5,4,3,2],5)[2]
#disc_edge = MDL_discretizer_iteration_converge(data,graph,discrete_index,continuous_index,5)
#disc_edge = disc_edge[2]
MY_disc_edge = Array(Any,5)
MY_disc_edge[5] = [8.0,14.05,24.8]
MY_disc_edge[4] = [1613.0,2217.0,2764.5,3030.0,3657.5,5140.0]
MY_disc_edge[3] = [9.0,17.65,22.75,28.9,46.6]
MY_disc_edge[2] = [46.0,71.5,99.0,123.5,230.0]
MY_disc_edge[1] = [68.0,70.5,106.0,159.5,190.5,259.0,284.5,455.0]

MDL_disc_edge = Array(Any,5)
MDL_disc_edge[5] = [8.0,13.75,24.8]
MDL_disc_edge[4] = [1613.0,2764.5,3657.5,5140.0]
MDL_disc_edge[3] = [9.0,46.6]
MDL_disc_edge[2] = [46.0,84.5,99.0,123.5,230.0]
MDL_disc_edge[1] = [68.0,455.0]

Y1 = sample_from_discetization(graph,data,[2,3,4,5,6],MY_disc_edge,300)
Y2 = sample_from_discetization(graph,data,[2,3,4,5,6],MDL_disc_edge,300)
