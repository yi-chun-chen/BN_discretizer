function combine_spouses_data(spouse_value_matrix)
        n_ins = length(spouse_value_matrix[:,1])

        combined_data = Array(Any,n_ins)
        for i = 1 : n_ins
                combined_data[i] = tuple(spouse_value_matrix[i,:]...)
        end

        return combined_data
end

function parent_class_combine(data_matrix,parent_set)
        n_parent = length(parent_set)
        N = length(data_matrix[:,1])

        parent_data_set = Array(Int64,N,n_parent)

        for i = 1 : n_parent
                parent_data_set[:,i] = data_matrix[:,parent_set[i]]
        end

        parent_data_set = combine_spouses_data(parent_data_set)

        class_combine = length(unique(parent_data_set))
        return class_combine
end

function log_prob_single_edge_last_term(class)
        n = length(class)
        uniq_cl = unique(class)
        val_cl = length(uniq_cl)

        distr_table = Array(Array,n)

        # Survey distribution for each data point

        for index_data = 1 : n
                class_cl = findfirst(uniq_cl,class[index_data])
                z = zeros(Int64,val_cl)
                z_modify = zeros(Int64,val_cl)
                z_modify[class_cl] = 1
                distr_table[index_data] = z_modify
        end

        # Survey class distribution between point i and point j

        distr_intval_table = Array(Array,n,n)

        for ind_init = 1 : n
                for ind_end = ind_init : n
                        if ind_init == ind_end
                                current_distr = distr_table[ind_init]
                        else
                                current_distr = distr_intval_table[ind_init,ind_end-1] +
                                                distr_table[ind_end]
                        end
                        distr_intval_table[ind_init,ind_end] = current_distr
                end
        end
        # println(distr_intval_table[1,n])
        # Get 1/P(D|M) for single edge case and count only last term in objective func

        inv_p = Array(Float64,n,n)

        for ind_init = 1 : n
                for ind_end = 1 : n
                        if ind_end < ind_init
                                inv_p[ind_init,ind_end] = Inf
                        else
                                distr_in_intval = distr_intval_table[ind_init,ind_end]
                                current = lfact(ind_end-ind_init+1)
                                for ind_cl = 1 : val_cl
                                        current -= lfact(distr_in_intval[ind_cl])
                                end

                                inv_p[ind_init,ind_end] = current
                        end
                end
        end

        return inv_p
end

function log_prob_spouse_child_data(child,spouse)
        n = length(child)
        uniq_sp = unique(spouse)
        uniq_ch = unique(child)
        val_sp = length(uniq_sp)
        val_ch = length(uniq_ch)

        distr_table = Array(Array,n,val_sp)

        # Survey distribution for each data point

        for index_data = 1 : n
                class_ch = findfirst(uniq_ch,child[index_data])
                class_sp = findfirst(uniq_sp,spouse[index_data])
                z = zeros(Int64,val_ch)
                z_modify = zeros(Int64,val_ch)
                z_modify[class_ch] = 1

                for class_sp_index = 1 : val_sp
                        if class_sp_index == class_sp
                                distr_table[index_data,class_sp_index] = z_modify
                        else
                                distr_table[index_data,class_sp_index] = z
                        end
                end
        end

        # Survey class distribution in between point i and point j

        distr_intval_table = Array(Array,n,n,val_sp)

        for ind_val_sp = 1 : val_sp
                for ind_init = 1 : n
                for ind_end = ind_init : n
                        if ind_init == ind_end
                                current_distr = distr_table[ind_end,ind_val_sp]
                        else
                                current_distr = distr_intval_table[ind_init,ind_end-1,ind_val_sp] +
                                                distr_table[ind_end,ind_val_sp]
                        end
                        #println(current_distr)
                        distr_intval_table[ind_init,ind_end,ind_val_sp] = current_distr
                end
                end
        end

        # Get the 1/P(D|M) for this child-spouse set

        inv_p = Array(Float64,n,n)

        for ind_init = 1 : n
        for ind_end = 1 : n
                if ind_end < ind_init
                        inv_p[ind_init,ind_end] = Inf
                else
                        current_val = 0.0
                        for ind_val_sp = 1 : val_sp
                                distr_in_intval = distr_intval_table[ind_init,ind_end,ind_val_sp]
                                total_num = sum(distr_in_intval)

                                # The forth term in objective function
                                current = lfact(total_num)
                                for ind_val_ch = 1 : val_ch
                                        current -= lfact(distr_in_intval[ind_val_ch])
                                end

                                # The third term in objective function
                                current += lfact(total_num + val_ch -1) - lfact(val_ch-1) - lfact(total_num)

                                # The 3rd and 4th terms for this value of spouse
                                current_val += current
                        end
                        inv_p[ind_init,ind_end] = current_val
                end
        end
        end



        return inv_p

end

child1 = [1,1,1,2];
spouse1 = [3,4,3,4];
spouse12 = [3,3,3,3];
child2 = [1,2,1,1,2,2,2,1,2,1]
spouse2 = [3,4,3,3,3,4,5,5,4,4]
log_prob_spouse_child_data(child1,spouse12)
#log_prob_single_edge_last_term(child1)

