include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("MDL_principle.jl")

f = open("abalone.data")

x = readlines(f)
data = Array(Float64,4177,9)
for i = 1 : 4177
        str = x[i]
        str_element = split(str,",")
        for j = 1 : 9
                if j == 1
                        if str_element[1] == "M"
                                data[i,1] = 1
                        else
                                data[i,1] = 2
                        end
                elseif j == 9
                        last_one = str_element[9]
                        data[i,9] = float(split(last_one,"\n")[1])
                else
                        data[i,j] = float(str_element[j])
                end
        end
end

sex = Array(Int64,4177)
for i = 1 : 4177
        sex[i] = data[i,1]
end

leng = Array(Float64,4177)
for i = 1 : 4177
        leng[i] = data[i,2]
end

diameter = equal_width_disc(data[:,3],5)
height = equal_width_disc(data[:,4],4)
who_w = equal_width_disc(data[:,5],5)
shu_w = equal_width_disc(data[:,6],3)
vis_w = equal_width_disc(data[:,7],4)
she_w = equal_width_disc(data[:,8],5)
age = equal_width_disc(data[:,9],4)

p = sortperm(leng)
leng = leng[p]
diameter = diameter[p]
height = height[p]
who_w = who_w[p]
shu_w = shu_w[p]
vis_w = vis_w[p]
she_w = she_w[p]

data_matrix = [sex age diameter height who_w shu_w vis_w she_w]

parent_set = [1,2]
child_spouse_set = [(5,3),(6,4),(7,4),8]

graph = [1 2 (1,2,3) 4 5 (3,4,6) (3,5,7) (3,5,8) (3,9)]

X = BN_discretizer_free_number_rep(leng,data_matrix,parent_set,child_spouse_set)
#MDL_discretizer_rep(leng,data_matrix,parent_set,child_spouse_set)
#0.075 0.4225 0.4775 0.5325 0.5725 0.5975 0.6175 0.6325 0.6775 0.7175 0.815
close(f)
