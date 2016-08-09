include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")

f = readcsv("data/iris.csv")
f = f[1:750]
f = reshape(f,5,150)
f = f'

data = Array(Any,150,5)

continuous_index = [1,2,3,4]
discrete_index = [5]

for i = 1 : 150
    for j = 1 : 5
        if j in discrete_index
            data[i,j] = round(Int64,f[i,j])
        else
            data[i,j] = f[i,j]
        end
    end

end



graph = [(5,1),(5,2),(5,3),(5,4)]

Order = graph_to_reverse_conti_order(graph,continuous_index)
cut_time = 5

n_fold = 2
data_group = cross_vali_data(n_fold,data)

test_error_p_my = 0; test_error_n_my = 0
test_error_p_MDL = 0; test_error_n_MDL = 0
log_li_my_wo = 0; log_li_MDL = 0
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
    MDL_disc_edge = MDL_discretizer_iteration_converge(train_data,graph,discrete_index,Order,cut_time)[2]
    reorder_my = sort_disc_by_vorder(Order,my_wo_disc_edge)
    reorder_MDL = sort_disc_by_vorder(Order,MDL_disc_edge)


    # MDL prediction
    for i = 1 : length(test_data[:,1])
        test_d = test_data[i,1:4]
        test_d1 = [test_d 1]
        test_d2 = [test_d 2]
        test_d3 = [test_d 3]
        new_data = [test_d1; test_d2; test_d3]

        li = likelihood_conti_each(graph,data,continuous_index,reorder_MDL,new_data,1)
        pred = indmax(li)

        if pred == test_data[i,5]
            test_error_p_MDL += 1
        else
            test_error_n_MDL += 1
        end

    end

    # MY prediction
    for i = 1 : length(test_data[:,1])
        test_d = test_data[i,1:4]
        test_d1 = [test_d 1]
        test_d2 = [test_d 2]
        test_d3 = [test_d 3]
        new_data = [test_d1; test_d2; test_d3]

        li = likelihood_conti_each(graph,data,continuous_index,reorder_my,new_data,1)
        pred = indmax(li)

        if pred == test_data[i,5]
            test_error_p_my += 1
        else
            test_error_n_my += 1
        end

    end

    # MDL likelohood
    log_li_my_wo += likelihood_conti(graph,train_data,continuous_index,reorder_my,test_data,1)
    log_li_MDL += likelihood_conti(graph,train_data,continuous_index,reorder_MDL,test_data,1)

end

#println(log_li_my_w,log_li_my_wo,log_li_MDL)
println(test_error_p_my/150)
println(test_error_p_MDL/150)
println(log_li_my_wo/150)
println(log_li_MDL/150)





#my_wo_disc_edge = BN_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time,false)[2]
#MDL_disc = MDL_discretizer_iteration_converge(data,graph,discrete_index,Order,cut_time)[2]
#reorder_MDL = sort_disc_by_vorder(Order,MDL_disc)

#train_error_p = 0; train_error_n = 0
#for i = 1 : 150
#    train_d = data[i,1:4]
#   train_d1 = [train_d 1]
#    train_d2 = [train_d 2]
#    train_d3 = [train_d 3]
#    new_data = [train_d1; train_d2; train_d3]

#    li = likelihood_conti_each(graph,data,continuous_index,reorder_MDL,new_data,1)
#    pred = indmax(li)

#    if pred == data[i,5]
#        train_error_p += 1
#    else
#        train_error_n += 1
#   end

#end
#pred_accuracy = train_error_p/150
#train_error_p/150 = 0.9466666666666667
