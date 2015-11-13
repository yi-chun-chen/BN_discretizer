include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")

f = readcsv("data/indian.csv")

data = Array(Any,579,11)

ind = 0
for i = 1 : length(f[:,1])
    if ~(i in [313,254,242,210])
        ind += 1
        data[ind,:] = f[i,:]
        if data[ind,2] == "Male"
            data[ind,2] = 1
        else
            data[ind,2] = 2
        end
    end
end


discrete_index = [2,11]
continuous_index = [1,3,4,5,6,7,8,9,10]

#data_integer = Array(Int64,size(data))
#for i = 1 : 10
#      if i in continuous_index
#               data_integer[:,i] = equal_width_disc(data[:,i],2)
#      else
#               data_integer[:,i] = data[:,i]
#      end
#end

#times = 10
#X = K2(data_integer,10,times)

graph = [4,6,11,3,(6,7),(7,4,5),10,(10,4,5,9),(9,4,5,6,1),(9,10,7,3,8),(5,2)]

Order = graph_to_reverse_conti_order(graph,continuous_index)
cut_time = 5

#my_w_disc_edge = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
#my_wo_disc_edge = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time,false)[2]
#MDL_disc_edge = MDL_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
#reorder_my_w_edge = sort_disc_by_vorder(Order,my_w_disc_edge)
#reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)
#reorder_MDL_edge = sort_disc_by_vorder(Order,MDL_disc_edge)
