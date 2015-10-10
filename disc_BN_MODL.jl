include("p_data_model.jl")

function prior_of_intval(continuous,lambda)
        N = length(continuous)
        d_1_N = continuous[N] - continuous[1]
        prior = Array(Float64,N)
        for i = 1 : N-1
                d_i = continuous[i+1] - continuous[i]
                prior[i] = 1 - exp(-lambda * d_i / d_1_N)
        end
        prior[N] = 1

        return prior
end

function largest_class_value(data_matrix)
        n = length(data_matrix[1,:])
        largest = 0
        for i = 1 : n
                class_value = length(unique(data_matrix[:,i]))
                if class_value > largest
                        largest = class_value
                end
        end

        return largest
end

#function parent_class_combine(data_matrix,parent_set)
#        total_class = 1
#        for i = 1 : length(parent_set)
#                total_class *= length(unique(data_matrix[:,parent_set[i]]))
#        end
#        return total_class
#end

function BN_discretizer_p_data_model(data_matrix,parent_set,child_spouse_set)

        N = length(data_matrix[:,1])
        n = length(data_matrix[1,:])
        n_p = length(parent_set)
        n_c = length(child_spouse_set)
        n_r = n_p + n_c

        parent_class_number = 1
        if length(parent_set) > 0
                for i = 1 : n_p
                        multi = length(unique(data_matrix[:,parent_set[i]]))
                        parent_class_number = parent_class_number * multi
                end

                parent_class_number_2 = parent_class_combine(data_matrix,parent_set)

                #println(("parent #",parent_class_number,parent_class_number_2))
        end

        # -log(P(D|M)) part:

        log_P_data_model = zeros(Float64,N,N)
        nearest_var_set = [parent_set,child_spouse_set]

        for ind_parent = 1 : n_p
                table = 0
                single_variable_data = data_matrix[:,parent_set[ind_parent]]
                table = log_prob_single_edge_last_term(single_variable_data)
                log_P_data_model += table
        end

        for ind_child = 1 : n_c
                table = 0
                if length(child_spouse_set[ind_child]) == 1
                        child_data = data_matrix[:,child_spouse_set[ind_child]]
                        spouse_data = zeros(Int64,N)
                        table = log_prob_spouse_child_data(child_data,spouse_data)

                elseif length(child_spouse_set[ind_child]) == 2
                        (child,spouse) = child_spouse_set[ind_child]
                        child_data = data_matrix[:,child]
                        spouse_data = data_matrix[:,spouse]
                        table = log_prob_spouse_child_data(child_data,spouse_data)
                else
                        # A child has more than 2 parents
                        child = child_spouse_set[ind_child][1]
                        child_data = data_matrix[:,child]
                        spouse_set = child_spouse_set[ind_child][2:]
                        spouse_matrix = Array(Int64,N,length(spouse_set))
                        for spouse_index = 1 : length(spouse_set)
                                spouse_matrix[:,spouse_index] = data_matrix[:,spouse_set[spouse_index]]
                        end
                        spouse_data = combine_spouses_data(spouse_matrix)
                        table = log_prob_spouse_child_data(child_data,spouse_data)
                end

                log_P_data_model += table
        end

        # Add -log(p_class_distribution_for_parent)


        for i = 1 : N
                for j = i : N
                        log_P_data_model[i,j] += lfact(j - i + parent_class_number) -
                                                 lfact(j-i+1) - lfact(parent_class_number-1)
                end
        end


        return log_P_data_model

end


function BN_discretizer_free_number(continuous,data_matrix,parent_set,child_spouse_set)
        p_data_model = BN_discretizer_p_data_model(data_matrix,parent_set,child_spouse_set)
        #lambda = div(largest_class_value(data_matrix),2)
        lambda = largest_class_value(data_matrix)
        split_on_intval = prior_of_intval(continuous,lambda)
        N = length(continuous)
        not_split_on_intval = ones(Float64,N) - split_on_intval


        smallest_value = Array(Float64,N)
        optimal_disc = Array(Array,N)
        length_conti_data = continuous[N] - continuous[1]

        for a = 1 : N
                if a == 1
                        smallest_value[1] = -log(split_on_intval[1]) + p_data_model[1,1]
                        optimal_disc[1] = [1]
                else
                        current_value = Inf
                        current_disc = [0]
                        for b = 1 : a
                                if b == a
                                        value = ((continuous[a] - continuous[1])/length_conti_data)*lambda -
                                                log(split_on_intval[a]) + p_data_model[1,a]

                                else
                                        value = smallest_value[b] +
                                        ((continuous[a] - continuous[b+1])/length_conti_data)*lambda -
                                        log(split_on_intval[a]) + p_data_model[b+1,a]
                                end

                                if value < current_value
                                        current_value = value
                                        if b == a
                                                current_disc = [a]
                                        else
                                                current_disc = [optimal_disc[b],a]
                                        end
                                end
                        end
                        smallest_value[a] = current_value
                        optimal_disc[a] = current_disc
                end
        end

        optimal_disc_value = Array(Float64,length(optimal_disc[N])+1)
        #println(optimal_disc[N])

        for i = 0 : length(optimal_disc[N])
                if i == 0
                        optimal_disc_value[1] = continuous[1]
                elseif i == length(optimal_disc[N])
                        optimal_disc_value[i+1] = continuous[end]
                else
                        optimal_disc_value[i+1] = 0.5 * (continuous[optimal_disc[N][i]]
                                                      +continuous[optimal_disc[N][i]+1])
                end
        end
        println(smallest_value[N])
        return optimal_disc_value

end

function BN_discretizer_fixed_number(continuous,data_matrix,parent_set,child_spouse_set,desired_num_bin)
        p_data_model = BN_discretizer_p_data_model(data_matrix,parent_set,child_spouse_set)
        #lambda = div(largest_class_value(data_matrix),2)
        lambda = largest_class_value(data_matrix)
        split_on_intval = prior_of_intval(continuous,lambda)
        N = length(continuous)
        not_split_on_intval = ones(Float64,N) - split_on_intval


        smallest_value = Array(Float64,N,desired_num_bin)
        optimal_disc = Array(Array,N,desired_num_bin)
        length_conti_data = continuous[N] - continuous[1]

        for i = 1 : desired_num_bin
                for j = 1 : N
                        if i > j
                                smallest_value[j,i] = Inf
                                optimal_disc[j,i] = [0]
                        end
                end
        end

        for k = 1 : desired_num_bin
                for j = k : N
                        #println([k,j])
                        if k == 1
                                smallest_value[j,k] = -log(split_on_intval[j]) + p_data_model[1,j] +
                                                     ((continuous[j]-continuous[1])/length_conti_data)*lambda
                                optimal_disc[j,k] = [j]
                        else
                                current_value = Inf
                                min_index = 0


                                for i = 1 : j-1
                                        second_piece_value = -log(split_on_intval[j]) + p_data_model[i+1,j] +
                                                            ((continuous[j]-continuous[i+1])/length_conti_data)*lambda

                                        temp_value = smallest_value[i,k-1] + second_piece_value

                                        if temp_value < current_value
                                                current_value = temp_value
                                                min_index = i
                                        end

                                end

                                smallest_value[j,k] = current_value
                                optimal_disc[j,k] = [optimal_disc[min_index,k-1] [j]]

                        end
                end
        end

        optimal_disc_w_1 = [[1] optimal_disc[N,desired_num_bin]]

        optimal_disc_value = Array(Float64,length(optimal_disc_w_1))

        for i = 1 : length(optimal_disc_w_1)
                if i == 1
                        optimal_disc_value[i] = continuous[1]
                elseif i == length(optimal_disc_w_1)
                        optimal_disc_value[i] = continuous[end]
                else
                        optimal_disc_value[i] = 0.5 * (continuous[optimal_disc_w_1[i]]
                                                      +continuous[optimal_disc_w_1[i]+1])
                end
        end

        return optimal_disc_value

end


##### Allow repetion #####


function BN_discretizer_free_number_rep(continuous,data_matrix,parent_set,child_spouse_set)
        p_data_model = BN_discretizer_p_data_model(data_matrix,parent_set,child_spouse_set)
        #lambda = div(largest_class_value(data_matrix),2)
        lambda = largest_class_value(data_matrix)
        split_on_intval = prior_of_intval(continuous,lambda)
        N = length(continuous)
        not_split_on_intval = ones(Float64,N) - split_on_intval

        conti_norep = unique(continuous)
        conti_head = Array(Int64,length(conti_norep))
        conti_tail = Array(Int64,length(conti_norep))
        N_norep = length(conti_norep)


        conti_head[1] = 1
        index_head = 1
        for i = 2 : N
                if continuous[i] != continuous[i-1]
                        index_head += 1
                        conti_head[index_head] = i
                end
        end

        conti_tail[end] = N
        index_tail = length(conti_norep)
        for i = N-1 : -1 : 1
                if continuous[i] != continuous[i+1]
                        index_tail -= 1
                        conti_tail[index_tail] = i
                end
        end

        #println(conti_tail==conti_head)
        smallest_value = Array(Float64,N_norep)
        optimal_disc = Array(Array,N_norep)
        length_conti_data = continuous[N] - continuous[1]

        for a = 1 : N_norep
                if a == 1
                        smallest_value[1] = -log(split_on_intval[conti_tail[1]]) +
                                                        p_data_model[conti_head[1],conti_tail[1]]
                        optimal_disc[1] = [conti_tail[1]]
                else
                        current_value = Inf
                        current_disc = [0]
                        for b = 1 : a
                                if b == a
                                        value =
                                        ( ( (continuous[conti_tail[a]] - continuous[1])/
                                                length_conti_data)*lambda) -
                                        log(split_on_intval[conti_tail[a]]) +
                                        p_data_model[1,conti_tail[a]]
                                else

                                        value = smallest_value[b] +
                                        ( ( (continuous[conti_tail[a]] - continuous[conti_head[b+1]])/
                                        length_conti_data)*lambda) -
                                        log(split_on_intval[conti_tail[a]]) +
                                        p_data_model[conti_head[b+1],conti_tail[a]]
                                end

                                if value < current_value
                                        current_value = value
                                        if b == a
                                                current_disc = [conti_tail[a]]
                                        else
                                                current_disc = [optimal_disc[b],conti_tail[a]]
                                        end
                                end
                        end
                        smallest_value[a] = current_value
                        optimal_disc[a] = current_disc
                end
        end

        #println(optimal_disc[end])
        optimal_disc_value = Array(Float64,length(optimal_disc[end])+1)

        for i = 0 : length(optimal_disc[end])
                if i == 0
                        optimal_disc_value[i+1] = continuous[1]
                elseif i == length(optimal_disc[end])
                        optimal_disc_value[i+1] = continuous[end]
                else
                        optimal_disc_value[i+1] = 0.5 * (continuous[optimal_disc[end][i]]
                                                      +continuous[optimal_disc[end][i]+1])
                end
        end
        #println(smallest_value[end])
        return optimal_disc_value

end




function BN_discretizer(continuous,data_matrix,parent_set,child_spouse_set,desired_num_bin = 0)
        if desired_num_bin == 0
                return BN_discretizer_free_number(continuous,data_matrix,parent_set,child_spouse_set)
        else
                return BN_discretizer_fixed_number(continuous,data_matrix,parent_set,child_spouse_set,desired_num_bin)
        end
end


#continuous = [1.0,1.1,2.0,2.5,3.0]
#d1_conti = [1.0,2.0,3.0,4.0,5.0,6.0]
#d1_class = [1,1,1,2,2,2]
#data_matrix = [[1 1 1 1 5],[1 1 1 2 6],[2 2 2 1 5],[2 2 1 1 6],[3 2 1 1 5]]
#parent_set = [1]
#child_spouse_set = [(2,5),(3,4,5)]
#BN_discretizer_p_data_model_v2(continuous,data_matrix,parent_set,child_spouse_set)
#TT = BN_discretizer_fixed_number(continuous,data_matrix,parent_set,child_spouse_set,3)

# Previous work
function optimal_1d_classifier(continuous,discrete_target)
        n = length(continuous)

        Disc_ijk_retval = Array(Array,n,n)
        Disc_ijk_MODL_value = Array(FloatingPoint,n,n)
        for j = 1:n
                for k = 1:n
                        if k > j
                                Disc_ijk_MODL_value[j,k] = Inf
                                Disc_ijk_retval[j,k] = [0]
                        end
                end
        end

        intval_distr_table = BN_discretizer_p_data_model(discrete_target,[],[1])

        for k = 1:n
                for j = k:n
                        if k == 1
                                Disc_ijk_retval[j,k] = [j]
                                Disc_ijk_MODL_value[j,k] = intval_distr_table[1,j]

                        else
                                MODL_value = Inf
                                select_intval = 0

                                for i = 1:j-1
                                        second_MODL = intval_distr_table[i+1,j]
                                        current_MODL = Disc_ijk_MODL_value[i,k-1] + second_MODL
                                        if current_MODL < MODL_value
                                                MODL_value = current_MODL
                                                select_intval = i
                                        end
                                end

                                Disc_ijk_retval[j,k] = append!(copy(Disc_ijk_retval[select_intval,k-1]),[j])
                                Disc_ijk_MODL_value[j,k] = MODL_value
                        end

                end
        end

        full_length_k_intval = copy(Disc_ijk_MODL_value[n,:])

        for l = 1:n
                full_length_k_intval[l] += lfact(n+l-1) - lfact(l-1) - lfact(n)
        end

        desired_intval_number = indmin(full_length_k_intval)

        bin_edges_index = Disc_ijk_retval[n,desired_intval_number]
        bin_edges = append!([1],bin_edges_index)

        bin_edge_value = Array(FloatingPoint,length(bin_edges))

        for index = 1 : length(bin_edge_value)
                if index == 1
                        bin_edge_value[index] = continuous[1]
                elseif index == length(bin_edge_value)
                        bin_edge_value[index] = continuous[end]
                else
                        bin_edge_value[index] = 0.5*(continuous[bin_edges[index]]+
                                                     continuous[bin_edges[index]+1])
                end
        end
        return bin_edge_value
end

# Equal width discretization
function equal_width_disc(continuous,m)

        N = length(continuous)
        min_value = minimum(continuous)
        max_value = maximum(continuous)
        span = (max_value - min_value)/m
        class_list = Array(Int64,N)

        for i = 1 : N
                class = div((continuous[i] - min_value),span)
                if class >= m
                        class -= 1
                end
                class_list[i] = class + 1
        end
        return class_list
end

function equal_width_edge(continuous,m)
        min_value = continuous[1]
        max_value = continuous[end]
        span = max_value - min_value
        edge = [continuous[1]]
        for i = 1 : m
                edge = [edge, min_value + (span/m)*i]
        end
        return edge
end

##### Adding an extra term for P(real_value_data | discretized_value_data)

function BN_discretizer_p_data_model_v2(continuous,data_matrix,parent_set,child_spouse_set)

        N = length(data_matrix[:,1])
        n = length(data_matrix[1,:])
        n_p = length(parent_set)
        n_c = length(child_spouse_set)
        n_r = n_p + n_c
        parent_class_number = parent_class_combine(data_matrix,parent_set)

        # -log(P(D|M)) part:

        log_P_data_model = zeros(Float64,N,N)
        nearest_var_set = [parent_set,child_spouse_set]

        for ind_parent = 1 : n_p
                table = 0
                single_variable_data = data_matrix[:,parent_set[ind_parent]]
                table = log_prob_single_edge_last_term(single_variable_data)
                log_P_data_model += table
        end

        for ind_child = 1 : n_c
                table = 0
                if length(child_spouse_set[ind_child]) == 1
                        child_data = data_matrix[:,child_spouse_set[ind_child]]
                        spouse_data = zeros(Int64,N)
                        table = log_prob_spouse_child_data(child_data,spouse_data)

                elseif length(child_spouse_set[ind_child]) == 2
                        (child,spouse) = child_spouse_set[ind_child]
                        child_data = data_matrix[:,child]
                        spouse_data = data_matrix[:,spouse]
                        table = log_prob_spouse_child_data(child_data,spouse_data)
                else
                        # A child has more than 2 parents
                        child = child_spouse_set[ind_child][1]
                        child_data = data_matrix[:,child]
                        spouse_set = child_spouse_set[ind_child][2:]
                        spouse_matrix = Array(Int64,N,length(spouse_set))
                        for spouse_index = 1 : length(spouse_set)
                                spouse_matrix[:,spouse_index] = data_matrix[:,spouse_set[spouse_index]]
                        end
                        spouse_data = combine_spouses_data(spouse_matrix)
                        table = log_prob_spouse_child_data(child_data,spouse_data)
                end

                log_P_data_model += table
        end

        # Add -log(p_class_distribution_for_parent)

        for i = 1 : N
                for j = i : N
                        log_P_data_model[i,j] += lfact(j - i + parent_class_number) -
                                                 lfact(j-i+1) - lfact(parent_class_number-1)
                end
        end

        # Add Probability(real value D | Discretizaed D )
        smallest_span = Inf
        for i = 1 : N-1
                span = continuous[i+1] - continuous[i]
                if span < smallest_span
                        smallest_span = span
                end
        end

        disc_position = Array(Float64,N+1)
        for i = 1 : N+1
                if i == 1
                        disc_position[1] = continuous[1] - 0.5 * smallest_span
                elseif i == N+1
                        disc_position[N+1] = continuous[N] + 0.5 * smallest_span
                else
                        disc_position[i] = 0.5 * (continuous[i] + continuous[i-1])
                end
        end
        largest_span = disc_position[N+1] - disc_position[1]
        for i = 1 : N
                for j = i : N
                        span_ratio = (disc_position[j+1] - disc_position[i])/largest_span
                        log_P_data_model[i,j] += (j-i+1) * log(span_ratio) - lfact(j-i+1)
                end
        end


        return log_P_data_model
end



function BN_discretizer_v2(continuous,data_matrix,parent_set,child_spouse_set)
        p_data_model = BN_discretizer_p_data_model_v2(continuous,data_matrix,parent_set,child_spouse_set)
        #lambda = div(largest_class_value(data_matrix),2)
        lambda = largest_class_value(data_matrix)
        split_on_intval = prior_of_intval(continuous,lambda)
        N = length(continuous)
        not_split_on_intval = ones(Float64,N) - split_on_intval
        parents_class = parent_class_combine(data_matrix,parent_set)

        smallest_value = Array(Float64,N)
        optimal_disc = Array(Array,N)
        length_conti_data = continuous[N] - continuous[1]

        for a = 1 : N
                if a == 1
                        smallest_value[1] = p_data_model[1,1]
                        optimal_disc[1] = [1]
                else
                        current_value = Inf
                        current_disc = [0]
                        for b = 1 : a-1
                                value = p_data_model[b+1,a]
                                if value < current_value
                                        current_value = value
                                        current_disc = [optimal_disc[b],a]
                                end
                        end
                        smallest_value[a] = current_value
                        optimal_disc[a] = current_disc
                end
        end

        optimal_disc_value = Array(Float64,length(optimal_disc[N]))

        for i = 1 : length(optimal_disc[N])
                if i == 1
                        optimal_disc_value[i] = continuous[1]
                elseif i == length(optimal_disc[N])
                        optimal_disc_value[i] = continuous[end]
                else
                        optimal_disc_value[i] = continuous[optimal_disc[N][i]]
                end
        end
        println(smallest_value[N])
        return optimal_disc_value

end
