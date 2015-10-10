include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")

function rand_seq(N)

        seq = Array(Int64,N)

        i = 1
        seq[1] = 1 + round(Int64, div(N * rand(),1) )

        while i < N
                number = 1 + int(div(N * rand(),1))
                if ~(number in seq[1:i])
                        i += 1
                        seq[i] = number
                end
        end
        return seq
end



function K2_f(x,parent)
        N = length(x)
        n = length(parent[1,:])

        # build carti product
        carti_set = [tuple(unique(parent[:,1])...)]

        for i = 2 : n
                carti_set = [carti_set;tuple(unique(parent[:,i])...)]
        end

        uni_x = unique(x); r = length(uni_x)
        carti_set = [carti_set;tuple(uni_x...)]

        CP = cartesian_product(carti_set)

        r_p = length(CP[:,1]) / r
        r_p = round(Int64,r_p)

        # Survey distribution
        count = zeros(Int64,length(CP[:,1]))

        for i = 1 : N
                reform_data = [parent[i,:] x[i]]
                for j = 1 : length(CP[:,1])
                        if reform_data == CP[j,:]
                                count[j] += 1
                        end
                end
        end

        # Sum over same parent value
        count_p = zeros(Int64,r_p)
        for i = 1 : r_p
                count_pp = 0
                for j = 1 : r
                        index = i + r_p * (j-1)
                        count_pp += count[index]
                end
                count_p[i] = count_pp
        end

        # Evaluate
        f = 0
        for i = 1 : r_p
                f += lfact(count_p[i]+r-1) - lfact(r-1)
        end
        for i = 1 : length(CP[:,1])
                f -= lfact(count[i])
        end


        return f
end

function parent_table_to_graph(parent_table)
        m = length(parent_table)
        # Parent_table -> graph
        graph = []
        for i = 1 : m
                child = i
                if length(parent_table[i]) == 0
                        graph = [graph,child]
                else
                parent = []
                for j = 1 : length(parent_table[i])
                        parent = [parent,parent_table[i][j]]
                end

                add = [parent,child]
                graph = [graph,tuple(add...)]
                end
        end
        return graph
end

function K2_one_iteration(order,u,data_matrix)
        N = length(data_matrix[:,1])
        m = length(data_matrix[1,:]) # number of variables

        # data that is sorted by order
        data = Array(Int64,size(data_matrix))
        for i = 1 : m
                data[:,i] = data_matrix[:,order[i]]
        end

        # Initialize graph structure

        parent_table = Array(Any,m)
        for i = 1 : m
                parent_table[i] = [] # No parent in the begining
        end

        # Iterate for all nodes
        for i = 1 : m
                p_old = K2_f(data[:,i],zeros(Int64,N))
                OKToProceed = true
                current_parent = []

                while OKToProceed & (length(parent_table[i]) < u)
                        # find node z for iteration
                        iteration_list = []
                        for j = 1 : i-1
                                if ~(j in current_parent)
                                        iteration_list = [iteration_list,j]
                                end
                        end

                        # iteration to find most probable
                        current_value = Inf
                        current_best_parent = []

                        for j = 1 : length(iteration_list)
                                iteration_parent = [current_parent,iteration_list[j]]
                                iteration_parent_data = data[:,iteration_parent[1]]
                                #if i ==4 ; println(iteration_parent); end;

                                for k = 2 : length(iteration_parent)
                                        iteration_parent_data = [iteration_parent_data data[:,iteration_parent[k]]]
                                end
                                this_iteration_value = K2_f(data[:,i],iteration_parent_data)


                                if this_iteration_value < current_value
                                        current_value = this_iteration_value
                                        current_best_parent = iteration_parent
                                end
                        end

                        if current_value < p_old
                                p_old = current_value
                                current_parent = current_best_parent
                                parent_table[i] = current_parent
                        else
                                OKToProceed = false
                        end

                end
                #println(("parent of",i,"is",parent_table[i]))
        end
        score = 0
        # Calculate score
        for i = 1 : m
                if length(parent_table[i]) == 0
                        score += K2_f(data[:,i],zeros(Int64,N))
                else
                        parent_data_final = Array(Int64,N,length(parent_table[i]))
                        for j = 1 : length(parent_table[i])
                                parent_data_final[:,j] = data[:,parent_table[i][j]]
                        end
                        score += K2_f(data[:,i],parent_data_final)
                end
        end

        # Parent_table -> graph
        graph = []
        for i = 1 : m
                child = order[i]
                if length(parent_table[i]) == 0
                        graph = [graph,child]
                else
                parent = []
                for j = 1 : length(parent_table[i])
                        parent = [parent,order[parent_table[i][j]]]
                end

                add = [parent,child]
                graph = [graph,tuple(add...)]
                end
        end


        return (graph,score)
end


function K2_one_iteration_discretization(order,u,data_matrix,continuous_index,cut_time)
        N = length(data_matrix[:,1])
        m = length(data_matrix[1,:]) # number of variables
        mc = length(continuous_index)

        # continuous/discrete index in the new order
        conti_index = Array(Int64,mc)
        disc_index = Array(Int64,m-mc)
        for i = 1 : mc
                conti_index[i] = findfirst(order,continuous_index[i])
        end
        conti_index = sort(conti_index, rev=true)

        index_disc = 0
        for i = 1 : m
                if ~(i in continuous_index)
                        index_disc += 1
                        disc_index[index_disc] = findfirst(order,i)
                end
        end

        # data that is sorted by order
        data = Array(Any,size(data_matrix))
        for i = 1 : m
                data[:,i] = data_matrix[:,order[i]]
                println(i)
        end

        # Initialize graph structure
        initial_lcard= 0
        data_discretized = Array(Int64,size(data_matrix))
        for i = 1 : m
                if ~(i in conti_index)
                        data_discretized[:,i] = data[:,i]
                        current_initial_lcard = length(unique(data[:,i]))

                        if current_initial_lcard > initial_lcard
                                initial_lcard = current_initial_lcard
                        end
                end
        end

        for i = 1 : m
                if i in conti_index
                        data_discretized[:,i] = equal_width_disc(data[:,i],initial_lcard)
                end
        end

        # Initialize graph structure
        parent_table = Array(Any,m)
        for i = 1 : m
                parent_table[i] = [] # No parent in the begining
        end
        # store discretization edges
        disc_edge = 0

        # Iterate for all nodes
        for i = 1 : m
                p_old = K2_f(data_discretized[:,i],zeros(Int64,N))
                OKToProceed = true
                current_parent = []

                while OKToProceed & (length(parent_table[i]) < u)
                        # find node z for iteration
                        iteration_list = []
                        for j = 1 : i-1
                                if ~(j in current_parent)
                                        iteration_list = [iteration_list;j]
                                end
                        end

                        # iteration to find most probable
                        current_value = Inf
                        current_best_parent = []


                        for j = 1 : length(iteration_list)

                                iteration_parent = [current_parent;iteration_list[j]]
                                iteration_parent_data = data_discretized[:,iteration_parent[1]]
                                #if i ==4 ; println(iteration_parent); end;

                                for k = 2 : length(iteration_parent)
                                        iteration_parent_data = [iteration_parent_data data_discretized[:,iteration_parent[k]]]
                                end
                                this_iteration_value = K2_f(data_discretized[:,i],iteration_parent_data)


                                if this_iteration_value < current_value
                                        current_value = this_iteration_value
                                        current_best_parent = iteration_parent
                                end
                        end


                        if current_value < p_old
                                p_old = current_value
                                current_parent = current_best_parent
                                parent_table[i] = current_parent
                                ###### Rediscretize ######
                                println((i,"th varaible"))
                                current_graph = parent_table_to_graph(parent_table)
                                disc_result = BN_discretizer_iteration_converge(data,current_graph,
                                                                               disc_index,conti_index,cut_time)

                                ##### Replace data_discretized #####

                                data_discretized = disc_result[1]
                                disc_edge = disc_result[2]

                        else

                                OKToProceed = false

                        end

                end
                #println(("parent of",i,"is",parent_table[i]))
        end

        score = 0
        # Calculate score
        for i = 1 : m
                if length(parent_table[i]) == 0
                        score += K2_f(data_discretized[:,i],zeros(Int64,N))
                else
                        parent_data_final = Array(Int64,N,length(parent_table[i]))
                        for j = 1 : length(parent_table[i])
                                parent_data_final[:,j] = data_discretized[:,parent_table[i][j]]
                        end
                        score += K2_f(data_discretized[:,i],parent_data_final)
                end
        end

        # Parent_table -> graph
        graph = []
        for i = 1 : m
                child = order[i]
                if length(parent_table[i]) == 0
                        graph = [graph,child]
                else
                parent = []
                for j = 1 : length(parent_table[i])
                        parent = [parent,order[parent_table[i][j]]]
                end

                add = [parent,child]
                graph = [graph,tuple(add...)]
                end
        end


        return (score,graph,disc_edge)
end


function K2_w_discretization(data_matrix,u,continuous_index,times,cut_time)

        score = Inf
        graph = 0
        disc_edge = 0

        for time = 1 : times
                # Produce random sequence of indexes
                println(("Iteration time =",time,"========================="))
                order = rand_seq(length(data_matrix[1,:]))
                iteration_result = K2_one_iteration_discretization(order,u,data_matrix,continuous_index,cut_time)

                if iteration_result[1] < score
                        score = iteration_result[1]
                        graph = iteration_result[2]
                        disc_edge = iteration_result[3]
                end
        end

        return (score,graph,disc_edge)
end

data_1 = [
1 0 0;
1 1 1;
0 0 1;
1 1 1;
0 0 0;
0 1 1;
1 1 1;
0 0 0;
1 1 1;
0 0 0]

data_2 = [
1 2 1 9;
1 2 1 9;
1 2 1 9;
1 2 2 9;
2 2 2 9;
2 1 2 8;
2 1 2 8;
2 1 2 8;
2 1 2 9;
2 1 1 8]

data_3 = Array(Any,10,5)
data_3[:,1:4] = data_2
data_3[:,5] = [
1.1;
2.2;
3.3;
4.4;
5.5;
6.6;
7.7;
8.0;
8.8;
9.9]

data_3_discretized = Array(Int64,10,5)
data_3_discretized[:,1:4] = data_2
data_3_discretized[:,5] = [1,1,1,2,2,2,3,3,3,3]
#X = K2_one_iteration([1,2,3],3,data)
K2_one_iteration_discretization([4,3,5,1,2],2,data_3,[5],5)
