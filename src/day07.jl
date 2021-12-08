module day07

using ..InlineTest

parse(io::IO) = [Base.parse(Int, line, base=10) for line in split(read(io, String), ',')]
solve(io::IO) = solve(parse(io))
function solve(v::AbstractVector{<:Integer})
    isempty(v) && return (0, 0)
	median = partialsort!(v, div(length(v), 2))
    mean = fld(sum(v, init=0), length(v))
    (part1, y1, y2) = reduce(v, init=(0, 0, 0)) do (part1, y1, y2), i
        d1, d2 = abs(mean - i), abs(mean + 1 - i)
        y1, y2 = y1 + d1 * (d1+1), y2 + d2 * (d2+1)
        (part1 + abs(median - i), y1, y2)
    end
    (part1, div(min(y1, y2), 2))
end

const TEST_STRING = """16,1,2,0,4,2,7,1,2,14"""

@testset "day07" begin
    @test solve(IOBuffer(TEST_STRING)) == (37, 168)
end

end # module
