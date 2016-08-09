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

discrete_index = [4,9]
continuous_index = [1,2,3,5,6,7,8,10,11,12,13,14]

graph =[5,(5,2),(5,8),(5,2,3),(3,5,2,9),(5,2,7),(9,3,2,10),(9,3,10,11),(7,13),1,(10,12),(13,14),4,(14,1,6)];

#cut_time = 10
#Order = graph_to_reverse_conti_order(graph,continuous_index)

n_fold = 10
data_group = cross_vali_data(n_fold,data)

block_disc_edge = 0
log_li_my_w = 0; log_li_my_wo = 0; log_li_MDL = 0; log_li_blocks = 0

for fold = 1 : n_fold
    println("fold = ", fold,"==============================")
    train_data = 0; test_data = 0
    if fold == 1
        test_data = data_group[fold]
        train_data = data_group[2]
        for j = 3 : n_fold
            train_data = [train_data;data_group[j]]
        end
    else
        test_data = data_group[fold]
        train_data = data_group[1]
        for j = 2 : n_fold
            if j != fold
                train_data = [train_data;data_group[j]]
            end
        end
    end

    my_wo_disc_edge = BN_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time,false)[2]
    reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)

    Li_my_wo = likelihood_conti(graph,train_data,continuous_index,reorder_my_wo_edge,test_data,1)
    log_li_my_wo += Li_my_wo

    #println("usssss")

    ############

    block_disc_edge = Array(Any,14)

    for conti_v = 1 : 12

        the_conti_index = continuous_index[conti_v]
        #block_disc_edge[conti_v] = equal_width_edge_no_sort(train_data[:,the_conti_index],6)
        block_disc_edge[conti_v] = binedges(DiscretizeBayesianBlocks(), convert(Vector{Float64}, train_data[:,the_conti_index]))

    end

    Li_block_w = likelihood_conti(graph,train_data,continuous_index,block_disc_edge,test_data,1)

    log_li_blocks += Li_block_w

    println((log_li_my_wo,log_li_blocks,fold))



end
#
#println(log_li_my_w,log_li_my_wo,log_li_MDL)

#my_w_disc_edge = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
#my_wo_disc_edge = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time,false)[2]
#MDL_disc_edge = MDL_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
#reorder_my_w_edge = sort_disc_by_vorder(Order,my_w_disc_edge)
#reorder_my_wo_edge = sort_disc_by_vorder(Order,my_wo_disc_edge)
#reorder_MDL_edge = sort_disc_by_vorder(Order,MDL_disc_edge)


#########################
### Data Generating 1 ###
#########################

#graph_1 = [5,(5,2),(5,8),(5,2,3),(3,5,2,9),(5,2,7),(9,3,2,10),(9,3,10,11),(7,13),1,(10,12),(13,14),4,(14,1,6)];

#my_wo = Array(Any,13)
#my_wo[1] = [0.00632,59.5283,81.25515,88.9762]
#my_wo[2] = [0.0,6.25,15.0,20.5,100.0]
#my_wo[3] = [0.46,7.225,8.005,8.35,9.125,16.57,18.84,20.735,27.74]
#my_wo[4] = [0.385,0.4405,0.486,0.491,0.496,0.519,0.522,0.528,0.541,0.5455,0.591,0.639,0.651,0.8205,0.871]
#my_wo[5] = [3.561,3.712,6.5425,7.437,8.78]
#my_wo[6] = [2.9,51.4,77.75,100.0]
#my_wo[7] = [1.1296,1.92035,2.58835,3.0793,4.48025,4.75025,12.1265]
#my_wo[8] = [187.0,190.5,306.0,309.0,402.5,407.0,567.5,688.5,711.0]
#my_wo[9] = [12.6,19.4,19.9,20.55,21.6,22.0]
#my_wo[10] = [0.32,150.345,357.485,389.2,396.9]
#my_wo[11] = [1.73,4.915,7.635,10.04,14.4,18.93,37.97]
#my_wo[12] = [5.0,14.05,18.15,21.85,26.45,37.45,50.0]

#Y1 = sample_from_discetization(graph_1,data,continuous_index,my_wo,2000)

#writecsv("housing_exp1_ourmethod.dat", Y1)
#writecsv("housing_raw.dat", data)


#########################
### Data Generating 2 ###
#########################

#graph_2 = [2,(2,7),12,(7,12,2,14),(2,12,14,6),4,(7,2,12,3),(14,7,6,13),(3,2,7,8),(12,3,1),(3,10),(3,5),(3,11),(10,11,2,9)];

#my_wo_2 = Array(Any,13)
#my_wo_2[1] = [0.00632,0.09215,0.234405,0.502405,1.090255,3.0438,59.5283,70.72745,81.25515,88.9762]
#my_wo_2[2] = [0.0,6.25,15.0,20.5,31.5,100.0]
#my_wo_2[3] = [0.46,3.875,3.985,6.145,6.305,7.225,7.625,9.125,9.795,10.7,16.57,18.84,20.735,23.77,27.74]
#my_wo_2[4] = [0.385,0.446,0.4485,0.4555,0.462,0.4705,0.491,0.496,0.5015,0.5085,0.5165,0.541,0.5485,0.5775,0.601,0.607,0.6115,0.619,0.6275,0.639,0.651,0.8205,0.871]
#my_wo_2[5] = [3.561,3.712,6.0985,6.5425,8.78]
#my_wo_2[6] = [2.9,77.5,100.0]
#my_wo_2[7] = [1.1296,2.58835,4.91495,12.1265]
#my_wo_2[8] = [187.0,190.5,260.0,264.5,276.5,278.0,302.0,306.0,312.0,377.0,387.5,394.5,402.5,407.0,431.0,434.5,453.0,567.5,688.5,711.0]
#my_wo_2[9] = [12.6,12.8,13.3,14.0,14.75,15.95,16.5,16.85,17.35,17.5,18.75,19.15,19.4,19.65,19.9,20.15,20.55,21.05,21.6,22.0]
#my_wo_2[10] = [0.32,396.9]
#my_wo_2[11] = [1.73,7.685,14.4,37.97]
#my_wo_2[12] = [5.0,18.15,21.85,26.45,50.0]

#Y3 = sample_from_discetization(graph_2,data,continuous_index,my_wo_2,2000)

#writecsv("housing_exp2_ourmethod.dat", Y3)

