module day01

using ..InlineTest

parse(io::IO) = [Base.parse(Int, line, base=10) for line in eachline(io)]
solve(io::IO) = solve(parse(io))
function solve(v::AbstractVector{<:Integer})
    zipdiff(a, b) = sum((@inbounds b[i] > a[i] for i in eachindex(b)), init=0)
    return (zipdiff(v, @view v[2:end]), zipdiff(v, @view v[4:end]))
end

const TEST_STRING = """199
200
208
210
200
207
240
269
260
263"""

@testset "day01" begin
    @test solve(IOBuffer(TEST_STRING)) == (7, 5)
end

end # module
