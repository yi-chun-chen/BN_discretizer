function Gaussian_distrib(mean,dev,n)
        A = Array(Float64,n)
        for i = 1 : n
                A[i] = dev * randn() + mean
        end

        return A
end

function uniform_distrib(a,b,n)
        A = Array(FloatingPoint,n)
        for i = 1 : n
                A[i] = a + (b-a) * rand()
        end

        return A
end

function Gaussian_distrib_single(mean,dev)
        a = dev * randn() + mean
        return a
end

function uniform_distrib_single(a,b)
        c = a + (b-a) * rand()

        return c
end
