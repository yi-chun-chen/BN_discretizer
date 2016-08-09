include("distrib_generator.jl")
include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")

n_sample = 500
conti = Gaussian_distrib(5,3,n_sample)

li_list = Array(Float64,45)

n_edge = 3

disc_edge = tuple(equal_width_edge_no_sort(data,n_edge)...)

#graph = [(1,2)]
#continuous_index = [2]
#discrete_index = [1]
#Order = graph_to_reverse_conti_order(graph,continuous_index)

n_fold = 20
data_group = cross_vali_data(n_fold,conti)

log_li = 0
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

    Li = likelihood_one_conti(train_data,disc_edge,test_data,1)

    log_li += Li
    println((log_li,fold))

end
#likelihood_conti_each(graph,train_data,continuous_index,disc_edge,new_data,prior_number=0)