include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")

f = readcsv("data/gituar.csv")

data = Array(Any,1200,8)
for i = 1 : 1200
    data[i,1:7] = [f[i+900,2] f[i+900,3] f[i+900,4] f[i+900,5] f[i+900,6] f[i+900,14] f[i+900,15]]
    data[i,8] =  round(Int64,f[i+900,16])
end

test_data = Array(Any,900,8)
for i = 1 : 900
    test_data[i,1:7] = [f[i,2] f[i,3] f[i,4] f[i,5] f[i,6] f[i,14] f[i,15]]
    test_data[i,8] =  round(Int64,f[i,16])
end

cut_time = 5
continuous_index = [1,2,3,4,5,6,7]
u = 2
times = 1
A = K2_w_discretization(data,u,continuous_index,times,cut_time)

graph = A[2]
my_disc = A[3]


train_error_p = 0; train_error_n = 0
for i = 901 : 2100
    println(("jiji",i-900))
    train_d = data[i-900,1:7]
    train_d1 = [train_d 1]
    train_d0 = [train_d 0]
    new_data = [train_d1; train_d0]
    println("yes")
    li = likelihood_conti_each(graph,data,continuous_index,my_disc,new_data,1)
    pred = 0
    if li[1] > li[2]
        pred = 1
    end
    if pred == data[i-900,8]
        train_error_p += 1
    else
        train_error_n += 1
    end

end


test_error_p = 0; test_error_n = 0
for i = 1 : 900
    println(("test",i))
    test_d = test_data[i,1:7]
    test_d1 = [test_d 1]
    test_d0 = [test_d 0]
    new_data = [test_d1; test_d0]
    li = likelihood_conti_each(graph,data,continuous_index,my_disc,new_data,1)
    pred = 0
    if li[1] > li[2]
        pred = 1
    end
    if pred == data[i,8]
        test_error_p += 1
    else
        test_error_n += 1
    end

end

println((train_error_p/1200, test_error_p/1200))

