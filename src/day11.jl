module day11

using ..InlineTest

const CI = CartesianIndex
const NEIGHBORS = Tuple(setdiff(CI(-1, -1):CI(1, 1), (CI(0, 0),)))

parse(io::IO) = mapreduce(i -> Base.parse.(UInt8, collect(i))', vcat, eachline(io))
solve(io::IO) = solve(parse(io))
function solve(M::AbstractMatrix{<:Integer})
    I = CartesianIndices(M)
    nflash_iter100 = 0
    iter_all_flash = nothing
    @inbounds for iteration in 1:typemax(Int)
        M .+= 1
        it_flash = 0
        converged = false
        while !converged
            converged = true
            for i in eachindex(M)
                if M[i] in 10:19
                    flash!(M, I, I[i])
                    it_flash += 1
                    converged = false
                end
            end
        end
        iteration ≤ 100 && (nflash_iter100 += it_flash)
        iter_all_flash === nothing && it_flash == 100 && (iter_all_flash = iteration)
        iter_all_flash !== nothing && iteration ≥ 100 && break
        foreach(i -> (M[i] > 9 && (M[i] = 0)), eachindex(M))
    end
    (nflash_iter100, Int(iter_all_flash))
end

function flash!(M::AbstractMatrix, I::CartesianIndices, j::CI)
    @inbounds M[j] = 20
    foreach(i -> (M[i] += 1), (i+j for i in NEIGHBORS if i+j ∈ I))
end

const TEST_STRING = """5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526"""

@testset "day11" begin
    @test solve(IOBuffer(TEST_STRING)) == (1656, 195)
end

end # module
