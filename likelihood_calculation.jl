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
                uniq_classes_tuple[i] = tuple([1:1:n_class[i]]...)
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




data_matrix =[
[1 3 6 1];
[2 4 7 1];
[2 4 6 1];
[1 3 6 1];
[1 3 5 1];
[1 4 6 2];
[1 4 5 2];
[2 4 7 2];
[2 4 6 1];
[2 4 7 1];
[1 3 6 2];
[2 3 6 1];
]

data_matrix_2 = [1;1;2];
TT = condi_prob_table(data_matrix)

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

#X = likelihood([1, (1,4)],data_matrix,data_matrix)

function continuous_to_discrete(data,bin_edge)
        #bin_edge_extend
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
