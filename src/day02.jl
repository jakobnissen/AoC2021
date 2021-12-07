module day02

using ..InlineTest

@enum Direction::UInt8 forward up down

function parse(io::IO)
    foldl(eachline(io), init=Tuple{Direction, Int}[]) do v, line
        isempty(strip(line)) && return v
        _direction, num = split(line, limit=2)
        direction =
            _direction == "forward" ? forward :
            _direction == "up" ? up :
            _direction == "down" ? down :
            error("Unknown direction $_direction")
        push!(v, (direction, Base.parse(Int, num, base=10)))
    end
end

solve(io::IO) = solve(parse(io))
solve(v::AbstractVector{<:Tuple{Direction, Integer}}) = part1(v), part2(v)

function part1(v::AbstractVector{<:Tuple{Direction, Integer}})
    h, d = 0, 0
    for (direction, n) in v
        (h, d) =
            direction == forward ? (h+n, d) :
            direction == up ? (h, d-n) :
            (h, d+n)
    end
    h * d
end

function part2(v::AbstractVector{<:Tuple{Direction, Integer}})
    h, d, a = 0, 0, 0
    for (direction, n) in v
        (h, d, a) =
            direction == forward ? (h+n, d+a*n, a) :
            direction == up ? (h, d, a-n) :
            (h, d, a+n)
    end
    h * d
end        

const TEST_STRING = """forward 5
down 5
forward 8
up 3
down 8
forward 2"""

@testset "day02" begin
    @test solve(IOBuffer(TEST_STRING)) == (150, 900)
end

end # module
