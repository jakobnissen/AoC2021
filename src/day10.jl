module day10

using ..InlineTest

const BracketScore = map(UInt16, (3, 57, 1197, 25137))
const BracketLUT = let
    a = fill(0xff, 128)
    for (i, c) in enumerate("()[]{}<>\n")
        a[Int(c)] = i - 1
    end
    Tuple(a)
end

@enum Bracket::UInt8 RL RR SL SR CL CR AL AR Break
isopen(b::Bracket) = iseven(Integer(b))
matching(b::Bracket) = reinterpret(Bracket, Integer(b) ⊻ 0x01)
score(b::Bracket) = @inbounds BracketScore[div(Integer(b), 2) + 1]
autoscore(b::Bracket) = div(Integer(b), 2) + 1

parse(io::IO) = map(b ->  Bracket(BracketLUT[b]), read(io))

mutable struct Stack{T}
    v::Vector{T}
    len::Int
end
Stack(::Type{T}) where T = Stack{T}(Vector{T}(undef, 512), 0)

function Base.pop!(s::Stack)
    if iszero(s.len)
        return nothing
    end
    y = @inbounds s.v[s.len]
    s.len -= 1
    y
end

function Base.push!(s::Stack{T}, v_) where T
    v = convert(T, v_)
    s.len += 1
    s.len > 512 && throw(StackOverflowError)
    @inbounds s.v[s.len] = v
    s
end

Base.empty!(s::Stack) = (s.len = 0)
Base.length(s::Stack) = s.len
Base.isempty(s::Stack) = iszero(length(s))

struct StackDrain{T}
    s::Stack{T}
end

drain!(s::Stack{T}) where T = StackDrain{T}(s)

function Base.iterate(s::StackDrain, i=s.s.len)
    iszero(i) && return nothing
    v = @inbounds s.s.v[i]
    s.s.len -= 1
    (v, i-1)
end

Base.eltype(::Type{StackDrain{T}}) where T = T
Base.length(s::StackDrain{T}) where T = length(s)

solve(io::IO) = solve(parse(io))
function solve(v::AbstractVector{Bracket})
    stack = Stack(Bracket)
    autocompletes = sizehint!(Int[], 100)
    part1 = 0
    skip = false
    for bracket in v
        if bracket == Break
            skip = false
            isempty(stack) || push!(autocompletes, foldl(drain!(stack), init=0) do n, i
                5n + autoscore(i)
            end)
            continue
        end
        skip && continue
        if isopen(bracket)
            push!(stack, bracket)
        elseif pop!(stack) !== matching(bracket)
            part1 += score(bracket)
            empty!(stack)
            skip = true
        end
    end
    (part1, partialsort!(autocompletes, div(length(autocompletes), 2) + 1))
end

const TEST_STRING = """[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]
"""

@testset "day10" begin
    @test solve(IOBuffer(TEST_STRING)) == (26397, 288957)
end

end # module
