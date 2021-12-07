module day06

using ..InlineTest

function parse(io::IO)
    foldl(split(read(io, String), ','), init=zeros(Int, 9)) do v, str
        v[Base.parse(UInt, str, base=10) + 1] += 1
        v
    end
end

solve(io::IO) = solve(parse(io))
function solve(nums::AbstractVector{<:Integer})
    length(nums) < 9 && error()
    v = copy(nums)
    part1 = 0
    @inbounds for gen in 1:256
        spawn = v[1]
        for i in 1:8
            v[i] = v[i+1]
        end
        v[9] = spawn
        v[7] += spawn
        gen == 80 && (part1 = sum(v))
    end
    (part1, sum(v))
end

const TEST_STRING = "3,4,3,1,2"

@testset "day06" begin
    @test solve(IOBuffer(TEST_STRING)) == (5934, 26984457539)
end

end # module
