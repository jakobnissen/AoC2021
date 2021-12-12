module day12

using ..InlineTest

struct Cave
    x::UInt8
    issmall::Bool
end

isend(x::Cave) = x.x == 63
isstart(x::Cave) = x.x == 0
endcave() = Cave(63, true)
startcave() = Cave(0, true)

struct CaveSet
    # End cave is top bit
    present::UInt64
    issmall::UInt64
end

CaveSet() = CaveSet(0, 0)
Base.length(s::CaveSet) = count_ones(s.present)
Base.in(c::Cave, s::CaveSet) = isodd(s.present >>> (c.x & 63))

function Base.iterate(s::CaveSet, state=s)
    iszero(state.present) && return nothing
    tz = trailing_zeros(state.present)
    cave = Cave(tz, isodd(state.issmall >>> (tz & 63)))
    (cave, CaveSet(state.present & (state.present - 1), state.issmall))
end

function push(s::CaveSet, c::Cave)
    bit = UInt64(1) << ((c.x) & 63)
    CaveSet(s.present | bit, s.issmall | ifelse(c.issmall, bit, 0))
end

mutable struct Stack{T}
    v::Vector{T}
    len::Int
end

function Stack(v::Vector{T}) where T
    L = length(v)
    Stack{T}(resize!(v, 1024), L)
end

function Base.pop!(s::Stack)
    iszero(s.len) && error()
    y = @inbounds s.v[s.len]
    s.len -= 1
    y
end

function Base.push!(s::Stack{T}, v_) where T
    v = convert(T, v_)
    s.len += 1
    s.len > 1024 && throw(StackOverflowError)
    @inbounds s.v[s.len] = v
    s
end

Base.isempty(s::Stack) = iszero(s.len)

function parse(io::IO)
    names = Dict{String, Int}()
    result = Vector{CaveSet}()
    for line in eachline(io)
        a, b = split(line, '-')
        ca, cb = from_name(a, names), from_name(b, names)
        addcave!(result, ca, cb)
        addcave!(result, cb, ca)
    end
    result
end

function from_name(s::AbstractString, d::Dict{String, Int})
    s == "end" && return endcave()
    s == "start" && return startcave()
    ns = get!(d, s, length(d) + 1)
    ns > 62 && error("Too many caves for set")
    Cave(ns, all(islowercase, s))
end

function addcave!(
    v::Vector{CaveSet},
    from::Cave,
    to::Cave
)
    (isstart(to) || isend(from)) && return v
    while length(v) < (from.x + 1)
        push!(v, CaveSet())
    end
    v[from.x + 1] = push(v[from.x + 1], to)
    v
end

solve(io::IO) = solve(parse(io))
function solve(v::Vector{CaveSet})
    stack = Stack([(CaveSet(), false, startcave())])
    paths_extravisit = 0
    paths_novisit = 0
    while !isempty(stack)
        hasbeen, small_visited, now = pop!(stack)
        for i in v[now.x + 1]
            if isend(i)
                paths_novisit += !small_visited
                paths_extravisit += 1
                continue
            end
            hasvisited = i.issmall && i ∈ hasbeen
            if hasvisited && small_visited
                continue
            end
            news = i.issmall ? push(hasbeen, i) : hasbeen
            push!(stack, (news, small_visited || hasvisited, i))
        end
    end
    return (paths_novisit, paths_extravisit)
end

const TEST_STRING_1 = """start-A
start-b
A-c
A-b
b-d
A-end
b-end"""

const TEST_STRING_2 = """dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc"""

const TEST_STRING_3 = """fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW"""

@testset "day01" begin
    @test solve(IOBuffer(TEST_STRING_1)) == (10, 36)
    @test solve(IOBuffer(TEST_STRING_2)) == (19, 103)
    @test solve(IOBuffer(TEST_STRING_3)) == (226, 3509)
end

end # module
