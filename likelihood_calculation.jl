include("distrib_generator.jl")

function cartesian_product(product_set)
        N = length(product_set)
        M = 1
        for i = 1 : N
                M *= length(product_set[i])
        end

        product_returned = [product_set[1]...]

        for class_index = 2 : N
                class_number = length(product_set[class_index])
                current_length = length(product_returned[:,1])

                enlarged_matrix = Array(Int64,current_length*class_number,class_index)

                if class_number == 1
                        enlarged_matrix[:,1:class_index-1] = product_returned
                        for i = 1 : current_length
                                enlarged_matrix[i,class_index] = product_set[class_index][1]
                        end
                else

                        for enlarge_times = 1 : class_number
                                enlarged_matrix[(enlarge_times-1)*current_length+1:enlarge_times*current_length,1:class_index-1] =
                                product_returned
                        end

                        for i = 1 : class_number * current_length
                                item_index = div(i-1,current_length) + 1
                                enlarged_matrix[i,class_index] = product_set[class_index][item_index]
                        end
                end
                product_returned = enlarged_matrix

        end

        return product_returned
end

function find_intval(x,disc)
    if x < disc[2]
        return 1
    end
    if x >= disc[end-1]
        return length(disc)-1
    end

    for i = 2 : length(disc)-2
           if (x >= disc[i])&(x < disc[i+1])
                   return i
           end
    end
end

function sampling_from_CPT(intval)
        x = rand()
        cum_intval = Array(Float64,1+length(intval))
        cum_intval[1] = 0
        for i = 1 : length(intval)
                cum_intval[i+1] = cum_intval[i] + intval[i]
        end
        #println(x)
        for i = 1 : length(intval)
                if (cum_intval[i]<x)&(x <= cum_intval[i+1])
                        return i
                end
        end
        if x < Inf
                return length(intval)
        end
end

function condi_prob_table(data_matrix,prior_number=0)
        # Initialization
        M = length(data_matrix[1,:])
        N = length(data_matrix[:,1])

        n_class = Array(Int64,M)
        uniq_classes = Array(Array,M)
        uniq_classes_tuple = Array(Any,M)

        if M == 1 # No parent case
                class_uniq = unique(data_matrix)
                class_number = length(class_uniq)
                count_table = prior_number * ones(Float64,class_number)


                for i = 1 : N
                        index = findfirst(class_uniq,data_matrix[i])
                        count_table[index] += 1
                end

                sum_all_class = sum(count_table)

                for i = 1 : class_number
                        count_table[i] = (count_table[i])/sum_all_class
                end

                return count_table


        else # Exists parents

        for i = 1 : M
                uniq_classes[i] = unique(data_matrix[:,i])
                n_class[i] = length(uniq_classes[i])
                uniq_classes_tuple[i] = tuple(collect(1:1:n_class[i])...)  ##### Might cause problem
        end

        # Count events
        count_table = prior_number * ones(Float64,tuple(n_class...))

        for inst = 1 : N
                class_index = zeros(Int64,M)
                for class_ind = 1 : M
                        class_index[class_ind] = findfirst(uniq_classes[class_ind],data_matrix[inst,class_ind])
                end

                class_index = tuple(class_index...)
                count_table[class_index...] += 1
        end

        # Normalization

        cart_class_product = cartesian_product(uniq_classes_tuple[1:end-1])

        for i = 1 : length(cart_class_product[:,1])
                product_index = tuple(cart_class_product[i,:]...)
                sum_for_norm = sum(count_table[product_index...,:])
                for j = 1 : length(count_table[product_index...,:])
                        if sum_for_norm != 0
                                count_table[product_index...,j] = (count_table[product_index...,j])/sum_for_norm
                        end
                end
        end

        return count_table

        end # end for if of number of parents


end

#data_matrix_2 = [1;1;2];
#TT = condi_prob_table(data_matrix)

#cartesian_product([(1,2),(4,5),(6,7)])

function likelihood(graph,train_data,new_data,prior_number=0)
        # graph consists of tuple elements that has the form (a,b,c,d), where a,b,c are parents of d.
        num_of_condi = length(graph)
        condi_collection = Array(Any,num_of_condi)

        for i = 1 : num_of_condi
                subgraph = graph[i]
                sub_data_matrix = [train_data[:,subgraph[1]]]

                for j = 2 : length(subgraph)
                        sub_data_matrix = [sub_data_matrix train_data[:,subgraph[j]]]
                end
                #println(condi_prob_table(sub_data_matrix))
                condi_collection[i] = condi_prob_table(sub_data_matrix,prior_number)
        end

        uniq_classes = Array(Any,length(train_data[1,:]))

        for i = 1 : length(train_data[1,:])
                uniq_classes[i] = unique(train_data[:,i])
        end

        LH = 0

        for i = 1 : length(new_data[:,1])
                LH_current = 0
                index_set = Array(Int64,length(new_data[1,:]))


                for j = 1 : length(index_set)
                        index_set[j] = findfirst(uniq_classes[j],new_data[i,j])
                end

                for g_ind = 1 : num_of_condi

                        sub_ind_set = Array(Int64,length(graph[g_ind]))

                        for k = 1 : length(graph[g_ind])
                                sub_ind_set[k] = index_set[graph[g_ind][k]]
                        end
                        sub_ind_set = tuple(sub_ind_set...)
                        p = condi_collection[g_ind][sub_ind_set...]
                        LH_current += log(p)

                end

                LH += LH_current
        end

        return LH
end

function continuous_to_discrete(data,bin_edge_1)
        #bin_edge_extend
        bin_edge = copy(bin_edge_1)
        bin_edge[1] = -Inf
        bin_edge[end] = Inf
        data_discrete = Array(Int64,length(data))
        for i = 1 : length(data)
                index = 0
                for j = 2 : length(bin_edge)
                        if (data[i] > bin_edge[j-1])&(data[i] <= bin_edge[j])
                                index = j-1
                        end
                end
                data_discrete[i] = index
        end
        return data_discrete
end


function likelihood_conti(graph,train_data,continuous_index,disc_edge,new_data,prior_number=0)
        # graph consists of tuple elements that has the form (a,b,c,d), where a,b,c are parents of d.
        num_of_condi = length(graph)
        condi_collection = Array(Any,num_of_condi)

        train_data_discretized = Array(Int64,size(train_data))
        for i = 1 : length(train_data[1,:])
                if i in continuous_index
                        index_in_disc_edge = findfirst(continuous_index,i)
                        train_data_discretized[:,i] = continuous_to_discrete(train_data[:,i],
                                                                              disc_edge[index_in_disc_edge])
                else
                        train_data_discretized[:,i] = train_data[:,i]
                end
        end

        for i = 1 : num_of_condi
                subgraph = graph[i]
                sub_data_matrix = Array(Int64,length(train_data[:,1]),length(subgraph))
                sub_data_matrix[:,1] = train_data_discretized[:,subgraph[1]]

                for j = 2 : length(subgraph)
                        sub_data_matrix[:,j] = train_data_discretized[:,subgraph[j]]
                end

                condi_collection[i] = condi_prob_table(sub_data_matrix,prior_number)
        end

        uniq_classes = Array(Any,length(train_data_discretized[1,:]))

        for i = 1 : length(train_data[1,:])
                uniq_classes[i] = unique(train_data_discretized[:,i])
        end

        LH = 0

        for i = 1 : length(new_data[:,1])
                LH_current = 0
                index_set = Array(Int64,length(new_data[1,:]))


                for j = 1 : length(index_set)
                        if j in continuous_index
                                index_in_disc_edge = findfirst(continuous_index,j)
                                index_intval = find_intval(new_data[i,j],disc_edge[index_in_disc_edge])
                                index_set[j] = findfirst(uniq_classes[j],index_intval)

                        else
                                index_set[j] = findfirst(uniq_classes[j],new_data[i,j])
                        end
                end

                for g_ind = 1 : num_of_condi

                        sub_ind_set = Array(Int64,length(graph[g_ind]))

                        for k = 1 : length(graph[g_ind])
                                sub_ind_set[k] = index_set[graph[g_ind][k]]
                        end
                        sub_ind_set = tuple(sub_ind_set...)

                        p = condi_collection[g_ind][sub_ind_set...]

                        LH_current += log(p)
                        #println(p)#if g_ind == 3; println(LH_current) ;end;
                        # Make a modification to continuous case
                        if (graph[g_ind][end] in continuous_index)
                                l = graph[g_ind][end]
                                index_in_disc_edge = findfirst(continuous_index,l)
                                index_intval = find_intval(new_data[i,l],disc_edge[index_in_disc_edge])
                                span = disc_edge[index_in_disc_edge][index_intval+1] - disc_edge[index_in_disc_edge][index_intval]
                                LH_current -= log(span)
                        end
                        #if g_ind == 3; println(LH_current) ;end;
                end

                LH += LH_current
        end

        return LH
end

#data_matrix_conti =[
#[1 3 1.1 7.0 1];
#[2 4 1.2 3.4 1];
#[2 4 2.1 6.4 1];
#[1 3 2.5 6.1 1];
#[1 3 3.1 5.9 1];
#[1 4 4.2 6.9 2];
#[1 4 5.5 5.1 2];
#[2 4 6.6 7.9 2];
#[2 4 7.2 6.2 1];
#[2 4 2.1 7.3 1];
#[1 3 3.1 6.7 1];
#[2 3 4.2 6.7 1];
#]
#continuous_index = [3,4];
#disc_edge = Array(Any,2)
#disc_edge[1] = [1.1,5.0,7.2]
#disc_edge[2] = [3.4,5.5,6.5,7.9]
#new_data_matrix = [
#[2 4 1.1 3.4 2];
#[1 3 6.0 7.2 1];
#]
#li = likelihood_conti([3,(3,4),1,(3,2),(3,4,5)],data_matrix_conti,continuous_index,disc_edge,new_data_matrix,1)


function sample_from_discetization(graph,train_data,continuous_index,disc_edge,number_of_samples,prior_number = 0)
        num_of_condi = length(graph)
        condi_collection = Array(Any,num_of_condi)

        train_data_discretized = Array(Int64,size(train_data))
        for i = 1 : length(train_data[1,:])
                if i in continuous_index
                        index_in_disc_edge = findfirst(continuous_index,i)
                        train_data_discretized[:,i] = continuous_to_discrete(train_data[:,i],
                                                                              disc_edge[index_in_disc_edge])
                else
                        train_data_discretized[:,i] = train_data[:,i]
                end
        end

        for i = 1 : num_of_condi
                subgraph = graph[i]
                sub_data_matrix = Array(Int64,length(train_data[:,1]),length(subgraph))
                sub_data_matrix[:,1] = train_data_discretized[:,subgraph[1]]

                for j = 2 : length(subgraph)
                        sub_data_matrix[:,j] = train_data_discretized[:,subgraph[j]]
                end

                condi_collection[i] = condi_prob_table(sub_data_matrix,prior_number)
        end

        uniq_classes = Array(Any,length(train_data_discretized[1,:]))

        for i = 1 : length(train_data[1,:])
                uniq_classes[i] = unique(train_data_discretized[:,i])
        end

        # Generate Data
        generate_data = Array(Any,number_of_samples, length(train_data[1,:]))
        for s = 1 : number_of_samples
                new_data_in_real = Array(Any,length(train_data[1,:]))
                new_data_in_uniq = Array(Int64,length(train_data[1,:]))
                for i = 1 : num_of_condi
                        if length(graph[i]) == 1
                                j = graph[i]
                                new_data_in_uniq[j] = sampling_from_CPT(condi_collection[i])
                        else
                                parent_data = Array(Int64,length(graph[i])-1)
                                for j = 1 : length(graph[i])-1
                                        parent_data[j] = new_data_in_uniq[graph[i][j]]

                                end
                                p_data = tuple(parent_data...)
                                CPT_ori = condi_collection[i][p_data...,:]
                                CPT = Array(Float64,length(CPT_ori))
                                for k = 1 : length(CPT_ori)
                                        CPT[k] = condi_collection[i][p_data...,k]
                                end
                                j = graph[i][end]
                                new_data_in_uniq[j] = sampling_from_CPT(CPT); #return new_data_in_uniq[i]
                        end
                        #if i == 1 ; return new_data_in_uniq[i];end;
                end
                #return new_data_in_uniq
                # transform back to real data values
                for i = 1 : length(new_data_in_uniq)
                        if i in continuous_index
                                intval_index = uniq_classes[i][new_data_in_uniq[i]]
                                disc = disc_edge[findfirst(continuous_index,i)]
                                new_data_in_real[i] = uniform_distrib_single(disc[intval_index],disc[intval_index+1])
                        else
                                new_data_in_real[i] = uniq_classes[i][new_data_in_uniq[i]]
                        end
                end
                generate_data[s,:] = new_data_in_real;
        end
        return generate_data
end

#X = likelihood_conti([3,(3,4),1,(3,2),(3,4,5)],data_matrix_conti,continuous_index,disc_edge,[1 3 6.0 7.2 1],1)
#X = sample_from_discetization([3,(3,4),1,(4,2),(3,4,5)],data_matrix_conti,continuous_index,disc_edge,2)

function sort_disc_by_vorder(continuous_order,disc_edge)
      reorder_disc_edge = Array(Any,length(continuous_order))
      for i = 1 : length(continuous_order)
            num_less = 1
            for j = 1 : length(continuous_order)
                  if continuous_order[j] < continuous_order[i]
                        num_less += 1
                  end
            end
            reorder_disc_edge[num_less] = disc_edge[i]
    end
    return reorder_disc_edge
end
#disc_edge_test = Array(Any,5)
#disc_edge_test[1] = [1.1,2.2,3.3]
#disc_edge_test[2] = [3.2,5.5]
#disc_edge_test[3] = [1,2,3]
#X = sort_disc_by_vorder([6,2,3],disc_edge_test)

function rand_seq(N)

        seq = Array(Int64,N)

        i = 1
        seq[1] = 1 + round(Int64, div(N * rand(),1) )

        while i < N
                number = 1 + round(Int64,div( N*rand(),1))
                if ~(number in seq[1:i])
                        i += 1
                        seq[i] = number
                end
        end
        return seq
end


function cross_vali_data(n_fold,data)
    N = length(data[:,1])
    n = length(data[1,:])

    data_store = Array(Any,n_fold)

    fold_contains = Array(Int64,n_fold)
    for i = 1 : n_fold-1
        fold_contains[i] = i * round(Int64,N/n_fold)
    end
    fold_contains[end] = N

    random_order = rand_seq(N)
    for i = 1 : n_fold
        if i < n_fold
            data_fold = Array(Any,round(Int64,N/n_fold),n)
        else
            data_fold = Array(Any,N-fold_contains[end-1],n)
        end

        if i == 1
            for j = 1 : fold_contains[i]
                data_fold[j,:] = data[random_order[j],:]
            end
        else
            k = 0
            for j = fold_contains[i-1] + 1 : fold_contains[i]
                k += 1
                data_fold[k,:] = data[random_order[j],:]
            end
        end
        data_store[i] = data_fold
    end
    return data_store
end



function likelihood_conti_each(graph,train_data,continuous_index,disc_edge,new_data,prior_number=0)
        # graph consists of tuple elements that has the form (a,b,c,d), where a,b,c are parents of d.
        num_of_condi = length(graph)
        condi_collection = Array(Any,num_of_condi)

        train_data_discretized = Array(Int64,size(train_data))
        for i = 1 : length(train_data[1,:])
                if i in continuous_index
                        index_in_disc_edge = findfirst(continuous_index,i)
                        train_data_discretized[:,i] = continuous_to_discrete(train_data[:,i],
                                                                              disc_edge[index_in_disc_edge])
                else
                        train_data_discretized[:,i] = train_data[:,i]
                end
        end

        for i = 1 : num_of_condi
                subgraph = graph[i]
                sub_data_matrix = Array(Int64,length(train_data[:,1]),length(subgraph))
                sub_data_matrix[:,1] = train_data_discretized[:,subgraph[1]]

                for j = 2 : length(subgraph)
                        sub_data_matrix[:,j] = train_data_discretized[:,subgraph[j]]
                end

                condi_collection[i] = condi_prob_table(sub_data_matrix,prior_number)
        end

        uniq_classes = Array(Any,length(train_data_discretized[1,:]))

        for i = 1 : length(train_data[1,:])
                uniq_classes[i] = unique(train_data_discretized[:,i])
        end

        LH = Array(Float64,length(new_data[:,1]))

        for i = 1 : length(new_data[:,1])
                LH_current = 0
                index_set = Array(Int64,length(new_data[1,:]))


                for j = 1 : length(index_set)
                        if j in continuous_index
                                index_in_disc_edge = findfirst(continuous_index,j)
                                index_intval = find_intval(new_data[i,j],disc_edge[index_in_disc_edge])
                                index_set[j] = findfirst(uniq_classes[j],index_intval)

                        else
                                index_set[j] = findfirst(uniq_classes[j],new_data[i,j])
                        end
                end

                for g_ind = 1 : num_of_condi

                        sub_ind_set = Array(Int64,length(graph[g_ind]))

                        for k = 1 : length(graph[g_ind])
                                sub_ind_set[k] = index_set[graph[g_ind][k]]
                        end
                        sub_ind_set = tuple(sub_ind_set...)

                        p = condi_collection[g_ind][sub_ind_set...]

                        LH_current += log(p)
                        #println(p)#if g_ind == 3; println(LH_current) ;end;
                        # Make a modification to continuous case
                        if (graph[g_ind][end] in continuous_index)
                                l = graph[g_ind][end]
                                index_in_disc_edge = findfirst(continuous_index,l)
                                index_intval = find_intval(new_data[i,l],disc_edge[index_in_disc_edge])
                                span = disc_edge[index_in_disc_edge][index_intval+1] - disc_edge[index_in_disc_edge][index_intval]
                                LH_current -= log(span)
                        end
                        #if g_ind == 3; println(LH_current) ;end;
                end

                LH[i] =  LH_current
        end

        return LH
end
