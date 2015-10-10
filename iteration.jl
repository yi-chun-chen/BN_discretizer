include("disc_BN_MODL.jl")

function graph_to_markov(graph,target)
        parent_set = []; child_spouse_set = [];
        for i = 1 : length(graph)

                condi_graph = graph[i]
                if length(condi_graph) == 1
                        if target == condi_graph
                                parent_set = []
                        end

                elseif target in condi_graph

                        index = findfirst(condi_graph,target)
                        if index == length(condi_graph)
                                parent_set = [condi_graph[1:end-1]...]
                        else

                                child = condi_graph[end]
                                spouse = []

                                for j = 1 : length(condi_graph)-1
                                        if j != index
                                                spouse = [spouse,condi_graph[j]]
                                        end
                                end
                                child_spouse_set = [child_spouse_set,tuple([child,spouse]...)]

                        end
                else

                end
        end

        for i = 1 : length(child_spouse_set)
                if length(child_spouse_set[i]) == 1
                        child_spouse_set = [child_spouse_set[1:i-1],child_spouse_set[i][1],child_spouse_set[i+1:end]]
                end
        end

        return (parent_set,child_spouse_set)
end

#graph = [1 2 (1,2,3) 4 5 6 (3,4,7) (3,8) (3,5,6,9)]

function one_iteration(data,data_integer,graph,discrete_index,continuous_index)
        # find largest cardinality
        #l_card = 0
        #for i = 1 : length(discrete_index)
        #        card = length(unique(data[:,discrete_index[i]]))
        #        if card > l_card
        #                l_card = card
        #        end
        #end

        # pre-equal-width-discretize on continuous variables
        #data_integer = zeros(Int64,size(data))
        #for i = 1 : length(discrete_index)
        #        index = discrete_index[i]
        #        data_integer[:,index] = data[:,index]
        #end

        #for i = 1 : length(continuous_index)
        #        index = continuous_index[i]
        #        data_integer[:,index] = equal_width_disc(data[:,index],l_card)
        #end

        # start one round iteration
        # data_integer keep changing based on discretization results

        # Save discretization edge
        disc_edge_collect = Array(Any,length(continuous_index))

        for i = 1 : length(continuous_index)
                target = continuous_index[i]

                increase_order = sortperm(data[:,target])
                conti = data[:,target][increase_order]
                data_integer_sort = Array(Int64,size(data))

                # sort data_integer properly
                for j = 1 : length(data_integer[1,:])
                        data_integer_sort[:,j] = data_integer[:,j][increase_order]
                end
                sets = graph_to_markov(graph,target)
                parent_set = sets[1]; child_spouse_set = sets[2];


                disc_edge = BN_discretizer(conti,data_integer_sort,parent_set,child_spouse_set)
                disc_edge_collect[i] = disc_edge

                # Update by current discretization
                data_integer[:,target] = continuous_to_discrete(data[:,target],disc_edge)
        end


        return (data_integer,disc_edge_collect)
end

#data = Array(Any,4,4)
#data[:,1] = [1,1,2,2]; data[:,2] = [2.2,0.9,2.1,2.3]; data[:,3] = [5,5,6,7]; data[:,4] = [3,4,4,4];

function BN_discretizer_iteration(data,graph,discrete_index,continuous_index,times)
        # intital the first data_integer
        l_card = 0
        for i = 1 : length(discrete_index)
                card = length(unique(data[:,discrete_index[i]]))
                if card > l_card
                        l_card = card
                end
        end

        # pre-equal-width-discretize on continuous variables
        data_integer = zeros(Int64,size(data))
        for i = 1 : length(discrete_index)
                index = discrete_index[i]
                data_integer[:,index] = data[:,index]
        end

        for i = 1 : length(continuous_index)
                index = continuous_index[i]
                data_integer[:,index] = equal_width_disc(data[:,index],l_card)
        end

        disc_edge_collect = Array(Any,length(continuous_index))

        # iteration for times
        for i = 1 : times
            X = one_iteration(data,data_integer,graph,discrete_index,continuous_index)
            data_integer = X[1]
            disc_edge_collect = X[2]

            uniq_classes = Array(Int64,length(continuous_index),1)
            for j = 1 : length(continuous_index)
                    uniq_classes[j] = length(unique(data_integer[:,continuous_index[j]]))
            end
            println(uniq_classes)
        end

        return disc_edge_collect
end
