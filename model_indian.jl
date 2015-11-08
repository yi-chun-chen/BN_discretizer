include("disc_BN_MODL.jl")
include("likelihood_calculation.jl")
include("iteration_2.jl")
include("K2.jl")

f = readcsv("data/indian.csv")

data = Array(Any,579,11)

ind = 0
for i = 1 : length(f[:,1])
    if ~(i in [313,254,242,210])
        ind += 1
        data[ind,:] = f[i,:]
        if data[ind,2] == "Male"
            data[ind,2] = 1
        else
            data[ind,2] = 2
        end
    end
end


discrete_index = [2,11]
continuous_index = [1,3,4,5,6,7,8,9,10]

data_integer = Array(Int64,size(data))
for i = 1 : 10
      if i in continuous_index
               data_integer[:,i] = equal_width_disc(data[:,i],2)
      else
               data_integer[:,i] = data[:,i]
      end
end

times = 1000
X = K2(data_integer,10,times)
