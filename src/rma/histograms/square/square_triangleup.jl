#
#       RMA Core - Get a random set of microstates available on the area above the main diagonal of a recurrence space, using the square shape.
#
"""
    dict_square_triangleup([x], [y], parameters, [structure], space_size::AbstractVector{Int}, func::F, dim::AbstractVector{Int}, hv::Int, samples::Int, metric::Metric)

Get a histogram of a random set of microstates available on each column of a recurrence space. The result is a dict with a probability distribution.
It is only available for 2D recurrence plot !!
"""
function dict_square_triangleup(x::Matrix{Float64}, y::Matrix{Float64}, parameters, structure::AbstractVector{Int},
    space_size::AbstractVector{Int}, func::F, dim::AbstractVector{Int}, hv::Int, samples::Int, metric::Metric) where {F}

    ##
    ##      Alloc memory for the histogram and the indeces list.
    hg = Dict{Int, Int}()
    idx = ones(Int, length(space_size))
    itr = zeros(Int, length(space_size))

    ##
    ##      Compute the power vector.
    p_vect = zeros(Int, hv)
    for i in 1:hv
        p_vect[i] = 2^(i - 1)
    end

    segment = (structure[2] + 1):(space_size[2] - (structure[2] - 1))

    ##
    ##      Get the samples and compute the histogram.
    @inbounds for _ in 1:samples
        idx[2] = rand(segment)
        idx[1] = rand(1:(idx[2] - structure[1]))

        p = @fastmath compute_index_square(x, y, parameters, structure, func, dim, idx, itr, p_vect, metric)
        hg[p] = get(hg, p, 0) + 1
    end

    ##
    ##      Return the histogram.
    return hg
end

"""
    dict_square_triangleup_async([x], [y], parameters, [structure], space_size::AbstractVector{Int}, func::F, dim::AbstractVector{Int}, hv::Int, samples::Int, metric::Metric)

Get a histogram of a random set of microstates available on each column of a recurrence space, using an async structure. The result is a dict with a probability distribution.
It is only available for 2D recurrence plot !!
"""
function dict_square_triangleup_async(x::Matrix{Float64}, y::Matrix{Float64}, parameters, structure::AbstractVector{Int},
    space_size::AbstractVector{Int}, func::F, dim::AbstractVector{Int}, hv::Int, samples::Int, metric::Metric) where {F}

    ##
    ##      Compute the power vector.
    p_vect = zeros(Int, hv)
    for i in 1:hv
        p_vect[i] = 2^(i - 1)
    end

    samp_segment = (structure[2] + 1):(space_size[2] - (structure[2] - 1))

    ##
    ##      Define a task to compute the histograms.
    function func_task(segment)
        ##
        ##      Alloc memory to the partial histogram, and the indeces.
        hg = Dict{Int, Int}()
        idx = zeros(Int, length(space_size))
        itr = zeros(Int, length(space_size))

        @inbounds for _ in segment
            idx[2] = rand(samp_segment)
            idx[1] = rand(1:(idx[2] - structure[1]))

            p = @fastmath compute_index_square(x, y, parameters, structure, func, dim, idx, itr, p_vect, metric)
            hg[p] = get(hg, p, 0) + 1
        end

        ##
        ##      Return the partial histogram.
        return hg
    end

    ##
    ##      Split the samples between the number of available threads.
    int_sampling_value = floor(Int, samples / Threads.nthreads())
    rest_sampling_value = samples % Threads.nthreads()

    ##
    ##      Initialize our tasks...
    tasks = []
    start_value = 1

    for _ in 1:Threads.nthreads()
        incrementor = int_sampling_value + (rest_sampling_value > 0 ? 1 : 0)
        segment = start_value:start_value + incrementor - 1

        push!(tasks, Threads.@spawn func_task(segment))

        start_value += incrementor
        rest_sampling_value -= 1
    end

    ##
    ##      Wait the result.
    result = fetch.(tasks)

    ##
    ##      Get the results
    res = Dict{Int, Int}()
    for r in result
        for (k, v) in r
            res[k] = get(res, k, 0) + v
        end
    end

    ##
    ##      Return the histogram.
    return res
end

"""
    vect_square_triangleup([x], [y], parameters, [structure], space_size::AbstractVector{Int}, func::F, dim::AbstractVector{Int}, hv::Int, samples::Int, metric::Metric)

Get a histogram of a random set of microstates available on each column of a recurrence space. The result is a vector with a probability distribution.
It is only available for 2D recurrence plot !!
"""
function vect_square_triangleup(x::Matrix{Float64}, y::Matrix{Float64}, parameters, structure::AbstractVector{Int},
    space_size::AbstractVector{Int}, func::F, dim::AbstractVector{Int}, hv::Int, samples::Int, metric::Metric) where {F}

    ##
    ##      Alloc memory for the histogram and the indeces list.
    hg = zeros(Int, 2^hv)
    idx = ones(Int, length(space_size))
    itr = zeros(Int, length(space_size))

    ##
    ##      Compute the power vector.
    p_vect = zeros(Int, hv)
    for i in 1:hv
        p_vect[i] = 2^(i - 1)
    end

    segment = (structure[2] + 1):(space_size[2] - (structure[2] - 1))

    ##
    ##      Get the samples and compute the histogram.
    @inbounds for _ in 1:samples
        idx[2] = rand(segment)
        idx[1] = rand(1:(idx[2] - structure[1]))

        p = @fastmath compute_index_square(x, y, parameters, structure, func, dim, idx, itr, p_vect, metric)
        hg[p] += 1
    end

    ##
    ##      Return the histogram.
    return hg
end

"""
    vect_square_triangleup_async([x], [y], parameters, [structure], space_size::AbstractVector{Int}, func::F, dim::AbstractVector{Int}, hv::Int, samples::Int, metric::Metric)

Get a histogram of a random set of microstates available on each column of a recurrence space, using an async structure. The result is a vector with a probability distribution.
It is only available for 2D recurrence plot !!
"""
function vect_square_triangleup_async(x::Matrix{Float64}, y::Matrix{Float64}, parameters, structure::AbstractVector{Int},
    space_size::AbstractVector{Int}, func::F, dim::AbstractVector{Int}, hv::Int, samples::Int, metric::Metric) where {F}

    ##
    ##      Compute the power vector.
    p_vect = zeros(Int, hv)
    for i in 1:hv
        p_vect[i] = 2^(i - 1)
    end

    samp_segment = (structure[2] + 1):(space_size[2] - (structure[2] - 1))

    ##
    ##      Define a task to compute the histograms.
    function func_task(segment)
        ##
        ##      Alloc memory to the partial histogram, and the indeces.
        hg = zeros(Int, 2^hv)
        idx = zeros(Int, length(space_size))
        itr = zeros(Int, length(space_size))

        @inbounds for _ in segment
            idx[2] = rand(samp_segment)
            idx[1] = rand(1:(idx[2] - structure[1]))

            p = @fastmath compute_index_square(x, y, parameters, structure, func, dim, idx, itr, p_vect, metric)
            hg[p] += 1
        end

        ##
        ##      Return the partial histogram.
        return hg
    end

    ##
    ##      Split the samples between the number of available threads.
    int_sampling_value = floor(Int, samples / Threads.nthreads())
    rest_sampling_value = samples % Threads.nthreads()

    ##
    ##      Initialize our tasks...
    tasks = []
    start_value = 1

    for _ in 1:Threads.nthreads()
        incrementor = int_sampling_value + (rest_sampling_value > 0 ? 1 : 0)
        segment = start_value:start_value + incrementor - 1

        push!(tasks, Threads.@spawn func_task(segment))

        start_value += incrementor
        rest_sampling_value -= 1
    end

    ##
    ##      Wait the result.
    result = fetch.(tasks)

    ##
    ##      Get the results
    res = zeros(Int, 2^hv)
    for r in result
        res .+= r
    end

    ##
    ##      Return the histogram.
    return res
end