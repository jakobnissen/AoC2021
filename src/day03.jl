module day03

parse(io::IO) = [Base.parse(UInt16, n, base=2) for n in eachline(io)]
solve(io::IO, bitwidth::Integer=12) = solve(parse(io), bitwidth)
function solve(nums::Vector{<:Unsigned}, bitwidth::Integer=12)
    gamma = most_common_bits(nums, bitwidth)
    part1 = Int(gamma * (~gamma & (1 << bitwidth - 1)))
    part2 = Int(
            Int(majority_bitsort!(nums, false, bitwidth)) * Int(majority_bitsort!(nums, true, bitwidth))
        )
    (part1, part2)
end

function most_common_bits(nums::Vector{<:Unsigned}, bitwidth)
    counts = zeros(UInt32, bitwidth)
    @inbounds for n in nums, shift in 0:bitwidth-1
        counts[shift+1] += isodd(n >>> shift)
    end
    mapreduce(|, enumerate(counts), init=UInt(0)) do (i, count)
        UInt(2count ≥ length(nums)) << (i-1)
    end
end

# Credit: Moritz Schauer
function majority_bitsort!(
    seqs::Vector{<:Unsigned},
    invert::Bool,
    bitpos=12,
    start=firstindex(seqs),
    stop=lastindex(seqs),
)
    while stop > start
        left = start
        right = stop
        bitpos > 0 || error("not found")
        bit = 1 << (bitpos-1)
        @inbounds while left < right
            if iszero(seqs[left] & bit)
                left += 1
            else
                seqs[left], seqs[right] = seqs[right], seqs[left]
                right -= 1
            end
        end
        n_zeros = (left - start) + iszero(@inbounds seqs[left] & bit)
        if (2 * n_zeros > (stop - start + 1)) ⊻ invert
            stop = start + n_zeros-1
        else
            start += n_zeros
        end
        bitpos -= 1
    end
    @inbounds seqs[start]
end

using ..InlineTest

const TEST_STRING = """00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010"""

@testset "day03" begin
    @test solve(IOBuffer(TEST_STRING), 5) == (198, 230)
end

end # module
