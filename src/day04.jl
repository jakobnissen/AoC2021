module day04

using ..InlineTest

struct BitMatrix25
    x::UInt32
end

function setindex(b::BitMatrix25, v::Bool, i::Integer)
    BitMatrix25(b.x | one(UInt32) << ((i - 1) & 31))
end

function Base.getindex(b::BitMatrix25, i::Integer)
    isodd(b.x >> ((i - 1) & 31))
end

mutable struct Board
    x::NTuple{25, UInt8}
    picked::BitMatrix25
end

Base.copy(b::Board) = Board(b.x, b.picked)

function parse(::Type{Board}, s::AbstractString)
    splits = split(s)
    tup = ntuple(i -> Base.parse(UInt8, splits[i], base=10), 25)
    Board(tup, BitMatrix25(0))
end

function parse(io::IO)
    s = join([strip(s) for s in eachline(io)], '\n')
    chunks = split(s, "\n\n")
    header = [Base.parse(UInt8, s, base=10) for s in split(first(chunks), ',')]
    (header, [parse(Board, i) for i in @view chunks[2:end]])
end

function is_bingo(b::Board)
    mask1 = 0b0000100001000010000100001
    mask2 = 0b0000000000000000000011111
    any(0:4) do i
        (b.picked.x >>> i & mask1) == mask1
    end ||
    any(0:4) do i
        (b.picked.x >>> (5i) & mask2) == mask2
    end
end

function pick_number!(b::Board, num::Integer)
    p = findfirst(i -> (@inbounds b.x[i]) == num, 1:25)
    p === nothing && return b
    b.picked = setindex(b.picked, true, p)
    b
end

function score(b::Board, num::Integer)
    num * sum(1:25, init=0) do i
        Int(b.x[i] * !b.picked[i])
    end
end

solve(io::IO) = solve(parse(io)...)
function solve(v::AbstractVector{<:Integer}, boards::Vector{Board})
    remaining = Set(copy(board) for board in boards)
    boardsof = Dict{eltype(v), Vector{Tuple{Board, UInt8}}}()
    for board in remaining, (i, num) in enumerate(board.x)
        push!(get!(valtype(boardsof), boardsof, num), (board, i % UInt8))
    end
    scores = Int[]
    for num in v
        for (board, i) in boardsof[num]
            board.picked = setindex(board.picked, true, i)
            if is_bingo(board)
                push!(scores, score(board, num))
                delete!(remaining, board)
                isempty(remaining) && return (first(scores), last(scores))
            end
        end
    end
    error()
end

const TEST_STRING = """7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7"""

@testset "day04" begin
    @test solve(IOBuffer(TEST_STRING)) == (4512, 1924)
end

end # module
