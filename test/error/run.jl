using RMA
using Colors
using CairoMakie
using Statistics
using Distributions
using RecurrenceAnalysis
using DifferentialEquations

using ProgressMeter

##
##
include("../systems.jl")

##
##      Settings
data_len = 3000
samples_percent = 0.05

num_tests = 100

##
##      Compute the errors
function compute()
    result = zeros(Float64, 5, 5, num_tests)
    determs = zeros(Float64, 2, 5, num_tests)
    lamis = zeros(Float64, 2, 5, num_tests)

    ##
    ##      Uniform Distribution.
    println("Running: Uniform Distribution")
    @showprogress for i in 1:num_tests
        ##
        ##      Generate the data.
        uniform = rand(Uniform(0, 1), data_len)
        thres, _ = RMA.find_parameters(uniform, 3)
        
        rq = rqa(RecurrenceMatrix(uniform, thres))
        rr = rq[:RR]
        det = rq[:DET]
        lam = rq[:LAM]

        
        rr_square = rrate(uniform, thres, 3; num_samples = samples_percent, shape = :square)
        rr_triangle = rrate(uniform, thres, 3; num_samples = samples_percent, shape = :triangle)
        rr_diagonal = rrate(uniform, thres, 3; num_samples = samples_percent, shape = :diagonal)
        rr_line = rrate(uniform, thres, 3; num_samples = samples_percent, shape = :line)
        rr_pair = rrate(uniform, thres, 3; num_samples = samples_percent, shape = :pair)

        #dist_square = distribution(uniform, thres, 3; shape = :square, sampling_mode = :full)
        #det_square = RMA.determinism(rr_square, dist_square; mode = :square)
        det_square = RMA.determinism(uniform, thres; mode = :square)
        det_diagonal = RMA.determinism(uniform, thres; mode = :diagonal)

        #lam_square = RMA.laminarity(rr_square, dist_square; mode = :square)
        lam_square = RMA.laminarity(uniform, thres; mode = :square)
        lam_line = RMA.laminarity(uniform, thres; mode = :line)

        result[1, 1, i] = (abs(rr_square - rr) / rr)
        result[2, 1, i] = (abs(rr_triangle - rr) / rr)
        result[3, 1, i] = (abs(rr_diagonal - rr) / rr)
        result[4, 1, i] = (abs(rr_line - rr) / rr)
        result[5, 1, i] = (abs(rr_pair - rr) / rr)

        determs[1, 1, i] = (abs(det_square - det) / det)
        determs[2, 1, i] = (abs(det_diagonal - det) / det)
        lamis[1, 1, i] = (abs(lam_square - lam) / lam)
        lamis[2, 1, i] = (abs(lam_line - lam) / lam)

        # println(string(rr, ", s: ", result[1, 1, i], ", t: ", result[2, 1, i], ", d: ", result[3, 1, i], ", c: ", result[4, 1, i], ", p: ", result[5, 1, i]))
    end

    ##
    ##      Lorenz System
    println("Running: Lorenz System")
    @showprogress for i in 1:num_tests
        ##
        ##      Generate the data.
        problem = ODEProblem(lorenz!, rand(Float64, 3), (0, 5000), [10.0, 28.0, 8.0/3.0])
        solution = solve(problem)

        ##      Prepare the solution.
        lorenz = prepare(solution, 0.2; transient = 10000, max_length = data_len)

        ##      Normalize the data
        norm_data = lorenz
        norm_data[1, :] .= (norm_data[1, :] .- mean(norm_data[1, :])) ./ std(norm_data[1, :])
        norm_data[2, :] .= (norm_data[2, :] .- mean(norm_data[2, :])) ./ std(norm_data[2, :])
        norm_data[3, :] .= (norm_data[3, :] .- mean(norm_data[3, :])) ./ std(norm_data[3, :])
        lorenz = norm_data

        ##      Get threshold.
        thres, _ = RMA.find_parameters(lorenz, 3; threshold_max = 10.0)
        
        rq = rqa(RecurrenceMatrix(StateSpaceSet(lorenz'), thres))
        rr = rq[:RR]
        det = rq[:DET]
        lam = rq[:LAM]
        
        rr_square = rrate(lorenz, thres, 3; num_samples = samples_percent, shape = :square)
        rr_triangle = rrate(lorenz, thres, 3; num_samples = samples_percent, shape = :triangle)
        rr_diagonal = rrate(lorenz, thres, 3; num_samples = samples_percent, shape = :diagonal)
        rr_line = rrate(lorenz, thres, 3; num_samples = samples_percent, shape = :line)
        rr_pair = rrate(lorenz, thres, 3; num_samples = samples_percent, shape = :pair)

        det_square = RMA.determinism(lorenz, thres; mode = :square)
        det_diagonal = RMA.determinism(lorenz, thres; mode = :diagonal)

        lam_square = RMA.laminarity(lorenz, thres; mode = :square)
        lam_line = RMA.laminarity(lorenz, thres; mode = :line)

        result[1, 2, i] = (abs(rr_square - rr) / rr)
        result[2, 2, i] = (abs(rr_triangle - rr) / rr)
        result[3, 2, i] = (abs(rr_diagonal - rr) / rr)
        result[4, 2, i] = (abs(rr_line - rr) / rr)
        result[5, 2, i] = (abs(rr_pair - rr) / rr)

        determs[1, 2, i] = (abs(det_square - det) / det)
        determs[2, 2, i] = (abs(det_diagonal - det) / det)
        lamis[1, 2, i] = (abs(lam_square - lam) / lam)
        lamis[2, 2, i] = (abs(lam_line - lam) / lam)

        # println(string("thres = ", thres, " | ", rr, ", s: ", result[1, 2, i], ", t: ", result[2, 2, i], ", d: ", result[3, 2, i], ", c: ", result[4, 2, i], ", p: ", result[5, 2, i]))
    end

    ##
    ##      Logistic Map
    println("Running: Logistic Map")
    @showprogress for i in 1:num_tests
        ##
        ##      Generate the data.
        logistic = logistic_map(4.0, data_len)
        thres, _ = RMA.find_parameters(logistic, 3)
        
        rq = rqa(RecurrenceMatrix(logistic, thres))
        rr = rq[:RR]
        det = rq[:DET]
        lam = rq[:LAM]
        
        rr_square = rrate(logistic, thres, 3; num_samples = samples_percent, shape = :square)
        rr_triangle = rrate(logistic, thres, 3; num_samples = samples_percent, shape = :triangle)
        rr_diagonal = rrate(logistic, thres, 3; num_samples = samples_percent, shape = :diagonal)
        rr_line = rrate(logistic, thres, 3; num_samples = samples_percent, shape = :line)
        rr_pair = rrate(logistic, thres, 3; num_samples = samples_percent, shape = :pair)

        det_square = RMA.determinism(logistic, thres; mode = :square)
        det_diagonal = RMA.determinism(logistic, thres; mode = :diagonal)

        lam_square = RMA.laminarity(logistic, thres; mode = :square)
        lam_line = RMA.laminarity(logistic, thres; mode = :line)

        result[1, 3, i] = (abs(rr_square - rr) / rr)
        result[2, 3, i] = (abs(rr_triangle - rr) / rr)
        result[3, 3, i] = (abs(rr_diagonal - rr) / rr)
        result[4, 3, i] = (abs(rr_line - rr) / rr)
        result[5, 3, i] = (abs(rr_pair - rr) / rr)

        determs[1, 3, i] = (abs(det_square - det) / det)
        determs[2, 3, i] = (abs(det_diagonal - det) / det)
        lamis[1, 3, i] = (abs(lam_square - lam) / lam)
        lamis[2, 3, i] = (abs(lam_line - lam) / lam)

        # println(string("thres = ", thres, " | ", rr, ", s: ", result[1, 3, i], ", t: ", result[2, 3, i], ", d: ", result[3, 3, i], ", c: ", result[4, 3, i], ", p: ", result[5, 3, i]))
    end

    ##
    ##      Lorenz System
    println("Running: Rössler System")
    @showprogress for i in 1:num_tests
        ##
        ##      Generate the data.
        problem = ODEProblem(rossler!, rand(Float64, 3), (0, 10000), [0.2, 0.2, 18.0])
        solution = solve(problem, Tsit5())
    
        rossler = prepare(solution, 0.18; transient = 20000, max_length = data_len)

        ##      Normalize the data
        norm_data = rossler
        norm_data[1, :] .= (norm_data[1, :] .- mean(norm_data[1, :])) ./ std(norm_data[1, :])
        norm_data[2, :] .= (norm_data[2, :] .- mean(norm_data[2, :])) ./ std(norm_data[2, :])
        norm_data[3, :] .= (norm_data[3, :] .- mean(norm_data[3, :])) ./ std(norm_data[3, :])
        rossler = norm_data

        thres, _ = RMA.find_parameters(rossler, 3; threshold_max = 10.0)
        
        rq = rqa(RecurrenceMatrix(StateSpaceSet(rossler'), thres))
        rr = rq[:RR]
        det = rq[:DET]
        lam = rq[:LAM]
        
        rr_square = rrate(rossler, thres, 3; num_samples = samples_percent, shape = :square)
        rr_triangle = rrate(rossler, thres, 3; num_samples = samples_percent, shape = :triangle)
        rr_diagonal = rrate(rossler, thres, 3; num_samples = samples_percent, shape = :diagonal)
        rr_line = rrate(rossler, thres, 3; num_samples = samples_percent, shape = :line)
        rr_pair = rrate(rossler, thres, 3; num_samples = samples_percent, shape = :pair)

        det_square = RMA.determinism(rossler, thres; mode = :square)
        det_diagonal = RMA.determinism(rossler, thres; mode = :diagonal)

        lam_square = RMA.laminarity(rossler, thres; mode = :square)
        lam_line = RMA.laminarity(rossler, thres; mode = :line)

        result[1, 4, i] = (abs(rr_square - rr) / rr)
        result[2, 4, i] = (abs(rr_triangle - rr) / rr)
        result[3, 4, i] = (abs(rr_diagonal - rr) / rr)
        result[4, 4, i] = (abs(rr_line - rr) / rr)
        result[5, 4, i] = (abs(rr_pair - rr) / rr)

        determs[1, 4, i] = (abs(det_square - det) / det)
        determs[2, 4, i] = (abs(det_diagonal - det) / det)
        lamis[1, 4, i] = (abs(lam_square - lam) / lam)
        lamis[2, 4, i] = (abs(lam_line - lam) / lam)

        # println(string("thres = ", thres, " | ", rr, ", s: ", result[1, 4, i], ", t: ", result[2, 4, i], ", d: ", result[3, 4, i], ", c: ", result[4, 4, i], ", p: ", result[5, 4, i]))
    end

    ##
    ##      Bernoulli Shifted Generalized (BSG / Beta-X)
    println("Running: BSG/Beta-X")
    @showprogress for i in 1:num_tests
        ##
        ##      Generate the data.
        bsg = beta_x(4.99, data_len)
        thres, _ = RMA.find_parameters(bsg, 3)
        
        rq = rqa(RecurrenceMatrix(bsg, thres))
        rr = rq[:RR]
        det = rq[:DET]
        lam = rq[:LAM]
        
        rr_square = rrate(bsg, thres, 3; num_samples = samples_percent, shape = :square)
        rr_triangle = rrate(bsg, thres, 3; num_samples = samples_percent, shape = :triangle)
        rr_diagonal = rrate(bsg, thres, 3; num_samples = samples_percent, shape = :diagonal)
        rr_line = rrate(bsg, thres, 3; num_samples = samples_percent, shape = :line)
        rr_pair = rrate(bsg, thres, 3; num_samples = samples_percent, shape = :pair)

        det_square = RMA.determinism(bsg, thres; mode = :square)
        det_diagonal = RMA.determinism(bsg, thres; mode = :diagonal)

        lam_square = RMA.laminarity(bsg, thres; mode = :square)
        lam_line = RMA.laminarity(bsg, thres; mode = :line)

        result[1, 5, i] = (abs(rr_square - rr) / rr)
        result[2, 5, i] = (abs(rr_triangle - rr) / rr)
        result[3, 5, i] = (abs(rr_diagonal - rr) / rr)
        result[4, 5, i] = (abs(rr_line - rr) / rr)
        result[5, 5, i] = (abs(rr_pair - rr) / rr)

        determs[1, 5, i] = (abs(det_square - det) / det)
        determs[2, 5, i] = (abs(det_diagonal - det) / det)
        lamis[1, 5, i] = (abs(lam_square - lam) / lam)
        lamis[2, 5, i] = (abs(lam_line - lam) / lam)

        # println(string("thres = ", thres, " | ", rr, ", s: ", result[1, 3, i], ", t: ", result[2, 3, i], ", d: ", result[3, 3, i], ", c: ", result[4, 3, i], ", p: ", result[5, 3, i]))
    end

    return result, determs, lamis
end

function graph()
    dataset, det, lam = compute()

    ##
    ##      Create the figure.
    fig = Figure(size = (1024, 920))

    ##
    ##      Categories for boxplot.
    cat = ones(Int, size(dataset, 3))
    for i = 2:size(dataset, 1)
        cat = vcat(cat, ones(Int, size(dataset, 3)) * i)
    end

    ##
    ##      Uniform distribution
    values = dataset[1, 1, :]
    for i = 2:size(dataset, 1)
        values =vcat(values, dataset[i, 1, :])
    end

    ax_u = Axis(fig[1, 1],
        xticks = (1:5, [":square", ":triangle", ":diagonal", ":line", ":pair"]),
        xgridvisible = false,
        ygridvisible = false,
        title = "a) Uniform Distribution",
        ylabel = "ΔError (%)")

    ax_u.ytickformat = y -> string.(round.(y, digits=2), "%")
    boxplot!(ax_u, cat, values .* 100, color = :orange)

    ##
    ##      Lorenz System
    values = dataset[1, 2, :]
    for i = 2:size(dataset, 1)
        values =vcat(values, dataset[i, 2, :])
    end

    ax_lz = Axis(fig[1, 2],
        xticks = (1:5, [":square", ":triangle", ":diagonal", ":line", ":pair"]),
        xgridvisible = false,
        ygridvisible = false,
        title = "b) Lorenz System",
        ylabel = "ΔError (%)")

    ax_lz.ytickformat = y -> string.(round.(y, digits=2), "%")
    boxplot!(ax_lz, cat, values .* 100, color = :orange)

    ##
    ##      Logistic Map
    values = dataset[1, 3, :]
    for i = 2:size(dataset, 1)
        values =vcat(values, dataset[i, 3, :])
    end

    ax_lm = Axis(fig[2, 1],
        xticks = (1:5, [":square", ":triangle", ":diagonal", ":line", ":pair"]),
        xgridvisible = false,
        ygridvisible = false,
        title = "c) Logistic Map",
        ylabel = "ΔError (%)")

    ax_lm.ytickformat = y -> string.(round.(y, digits=2), "%")
    boxplot!(ax_lm, cat, values .* 100, color = :orange)

    ##
    ##      Rössler System
    values = dataset[1, 4, :]
    for i = 2:size(dataset, 1)
        values =vcat(values, dataset[i, 4, :])
    end

    ax_r = Axis(fig[2, 2],
        xticks = (1:5, [":square", ":triangle", ":diagonal", ":line", ":pair"]),
        xgridvisible = false,
        ygridvisible = false,
        title = "d) Rössler System",
        ylabel = "ΔError (%)")

    ax_r.ytickformat = y -> string.(round.(y, digits=2), "%")
    boxplot!(ax_r, cat, values .* 100, color = :orange)

    ##
    ##      BSG
    values = dataset[1, 5, :]
    for i = 2:size(dataset, 1)
        values =vcat(values, dataset[i, 5, :])
    end

    ax_b = Axis(fig[3, 1],
        xticks = (1:5, [":square", ":triangle", ":diagonal", ":line", ":pair"]),
        xgridvisible = false,
        ygridvisible = false,
        title = "e) Bernoulli Shifted Generalized",
        ylabel = "ΔError (%)")

    ax_b.ytickformat = y -> string.(round.(y, digits=2), "%")
    boxplot!(ax_b, cat, values .* 100, color = :orange)

    ##
    ##      Overview
    values = reshape(dataset, size(dataset, 1), size(dataset, 2) * size(dataset, 3))
    cat = ones(Int, size(values, 2))
    for i = 2:size(dataset, 1)
        cat = vcat(cat, ones(Int, size(values, 2)) * i)
    end

    values = reshape(values, size(values, 1) * size(values, 2))
    cat = reshape(cat, size(cat, 1) * size(cat, 2))

    ax_o = Axis(fig[3, 2],
        xticks = (1:5, [":square", ":triangle", ":diagonal", ":line", ":pair"]),
        xgridvisible = false,
        ygridvisible = false,
        title = "f) Overview",
        ylabel = "ΔError (%)")

    ax_o.ytickformat = y -> string.(round.(y, digits=2), "%")
    boxplot!(ax_o, cat, values .* 100)

    ##
    save("test/rr_error/fig.png", fig)

    ## =============================================================================================
    ##      Determinism
    fig_2 = Figure(size = (1024, 420))

    ##
    ##      Categories for boxplot.
    cat = ones(Int, size(dataset, 3), 6)
    cat[:, 2] .*= 2
    cat[:, 3] .*= 3
    cat[:, 4] .*= 4
    cat[:, 5] .*= 5
    cat[:, 6] .*= 6

    ax_1 = Axis(fig_2[1, 1],
        xticks = (1:6, ["(i)", "(ii)", "(iii)", "(iv)", "(v)", "Overview"]),
        xgridvisible = false,
        ygridvisible = false,
        title = "a) Square Motifs",
        ylabel = "ΔError (%)")

    ax_1.ytickformat = y -> string.(round.(y, digits=2), "%")
    boxplot!(ax_1, cat[:, 1], det[1, 1, :] .* 100, colormap = :Set2_6)
    boxplot!(ax_1, cat[:, 2], det[1, 2, :] .* 100, colormap = :Set2_6)
    boxplot!(ax_1, cat[:, 3], det[1, 3, :] .* 100, colormap = :Set2_6)
    boxplot!(ax_1, cat[:, 4], det[1, 4, :] .* 100, colormap = :Set2_6)
    boxplot!(ax_1, cat[:, 5], det[1, 5, :] .* 100, colormap = :Set2_6)

    overview_1 = reshape(det[1, :, :], size(det, 2) * size(det, 3))

    boxplot!(ax_1, cat[:, 6], overview_1 .* 100, colormap = :Set2_6)

    ax_2 = Axis(fig_2[1, 2],
        xticks = (1:6, ["(i)", "(ii)", "(iii)", "(iv)", "(v)", "Overview"]),
        xgridvisible = false,
        ygridvisible = false,
        title = "b) Diagonal Motifs",
        ylabel = "ΔError (%)")

    ax_2.ytickformat = y -> string.(round.(y, digits=2), "%")
    boxplot!(ax_2, cat[:, 1], det[2, 1, :] .* 100, colormap = :Set2_6)
    boxplot!(ax_2, cat[:, 2], det[2, 2, :] .* 100, colormap = :Set2_6)
    boxplot!(ax_2, cat[:, 3], det[2, 3, :] .* 100, colormap = :Set2_6)
    boxplot!(ax_2, cat[:, 4], det[2, 4, :] .* 100, colormap = :Set2_6)
    boxplot!(ax_2, cat[:, 5], det[2, 5, :] .* 100, colormap = :Set2_6)

    overview_2 = reshape(det[2, :, :], size(det, 2) * size(det, 3))

    boxplot!(ax_2, cat[:, 6], overview_2 .* 100, colormap = :Set2_6)

    save("test/rr_error/fig2.png", fig_2)


    ## =============================================================================================
    ##      Laminarity
    fig_3 = Figure(size = (1024, 420))

    ax_3 = Axis(fig_3[1, 1],
        xticks = (1:6, ["(i)", "(ii)", "(iii)", "(iv)", "(v)", "Overview"]),
        xgridvisible = false,
        ygridvisible = false,
        title = "a) Square Motifs",
        ylabel = "ΔError (%)")

    ax_3.ytickformat = y -> string.(round.(y, digits=2), "%")
    boxplot!(ax_3, cat[:, 1], lam[1, 1, :] .* 100, colormap = :Set2_6)
    boxplot!(ax_3, cat[:, 2], lam[1, 2, :] .* 100, colormap = :Set2_6)
    boxplot!(ax_3, cat[:, 3], lam[1, 3, :] .* 100, colormap = :Set2_6)
    boxplot!(ax_3, cat[:, 4], lam[1, 4, :] .* 100, colormap = :Set2_6)
    boxplot!(ax_3, cat[:, 5], lam[1, 5, :] .* 100, colormap = :Set2_6)

    overview_3 = reshape(lam[1, :, :], size(lam, 2) * size(lam, 3))

    boxplot!(ax_3, cat[:, 6], overview_3 .* 100, colormap = :Set2_6)

    ax_4 = Axis(fig_3[1, 2],
        xticks = (1:6, ["(i)", "(ii)", "(iii)", "(iv)", "(v)", "Overview"]),
        xgridvisible = false,
        ygridvisible = false,
        title = "b) Line Motifs",
        ylabel = "ΔError (%)")

    ax_4.ytickformat = y -> string.(round.(y, digits=2), "%")
    boxplot!(ax_4, cat[:, 1], lam[2, 1, :] .* 100, colormap = :Set2_6)
    boxplot!(ax_4, cat[:, 2], lam[2, 2, :] .* 100, colormap = :Set2_6)
    boxplot!(ax_4, cat[:, 3], lam[2, 3, :] .* 100, colormap = :Set2_6)
    boxplot!(ax_4, cat[:, 4], lam[2, 4, :] .* 100, colormap = :Set2_6)
    boxplot!(ax_4, cat[:, 5], lam[2, 5, :] .* 100, colormap = :Set2_6)

    overview_4 = reshape(lam[2, :, :], size(lam, 2) * size(lam, 3))

    boxplot!(ax_4, cat[:, 6], overview_4 .* 100, colormap = :Set2_6)

    save("test/rr_error/fig3.png", fig_3)
end

graph()