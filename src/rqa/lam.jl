#
#           RMA Analysis
#
#       TODO: Adapt for any `n` size, not just 3.
"""
    laminarity(rr:Float64, [probs]; {mode})

Compute the laminarity of a problem, using a estimation proposed by [Felipe2025](@cite). We have two
ways to do it, using a square motif (mode :square) or using a diagonal motif that contains (the default mode :column)
"""
function laminarity(rr::Float64, probs::Vector{Float64}; mode::Symbol = :column)
    if (length(probs) != 512 && length(probs) != 8)
        throw(ArgumentError(string("Determinism must be computed using square motifs with n = 3. Actual value results in ", length(probs))))
    end

    ##  TODO : Maybe it can be removed.
    function __default_mode()
        ##
        ##      Compute the indeces...
        values = zeros(Int, 64)
        v_idx = 1

        for a1 in 0:1, a2 in 0:1, a3 in 0:1, a4 in 0:1, a5 in 0:1, a6 in 0:1
            I_1 = 2 + 8 * a1 + 16 * a2 + 32 * a3 + 64 * a4 + 128 * a5 + 256 * a6
            values[v_idx] = I_1
            v_idx += 1
        end

        ##
        ##      Sum the probabilities that we need.
        pl = 0.0
        for i in values
            pl += probs[i]
        end

        ##
        ##      Return the determinism.
        return 1 - ((1/rr) * pl)
    end

    function  __column_mode()
        ##
        ##      With column mode we need only a specific probability, the motif (0 1 0) with index 2 (3 in Julia).
        return 1 - ((1/rr) * probs[3])
    end

    ##
    ##      Compute the determinism.
    return mode == :column ? __column_mode() : __default_mode()
end
"""
    laminarity([x], threshold::Float64; {mode}, {num_samples})

This function uses a recurrence rate from the probabilities used also to compute the laminarity, so we have a error in the recurrence rate
that can result in a error of ~ 5% for the determinism.
"""
function laminarity(x::AbstractArray, threshold::Float64;  mode::Symbol = :column, num_samples::Union{Int, Float64} = 0.09)
    ##
    ##      Compute the probabilities.
    probs = distribution(x, (0.0, threshold), 3; shape = mode == :column ? :column : :square, num_samples = num_samples)
    ##
    ##      Compute the recurrence rate.
    rr = rrate(probs)
    ##
    ##      Return the determinism.
    return laminarity(rr, probs; mode = mode)
end