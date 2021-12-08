module day08

using ..InlineTest

const UTF8 = Union{String, SubString{String}}

struct SegmentSet
    x::UInt8
end

function parse(::Type{SegmentSet}, s::UTF8)
    reduce(codeunits(s), init=0x00) do x, i
        x | 0x01 << ((i - UInt8('a')) & 7)
    end |> SegmentSet
end

Base.length(x::SegmentSet) = count_ones(x.x)
Base.intersect(a::SegmentSet, b::SegmentSet) = SegmentSet(a.x & b.x)

struct Record
    signal::NTuple{10, SegmentSet}
    output::NTuple{4, SegmentSet}
end

# TODO: Optimize
function parse(::Type{Record}, s::UTF8)
    s1, s2 = split(s, " | ")
    a = Tuple(sort!(map(i -> parse(SegmentSet, i), split(s1)), by=length))
    b = Tuple(map(i -> parse(SegmentSet, i), split(s2)))
    Record(a, b)
end

parse(io::IO) = map(L -> parse(Record, strip(L)), eachline(io))
solve(io::IO) = solve(parse(io))
solve(v::AbstractVector{Record}) = (part1(v), part2(v))

function part1(v::AbstractVector{Record})
    sum(v) do record
        sum(record.output) do set
            length(set) in (2, 3, 4, 7)
        end
    end
end

function part2(v::AbstractVector{Record})
    sum(v) do record
        _1, _4 = record.signal[1], record.signal[3]
        foldl(record.output, init=0) do n, i
            L = length(i)
            m = if L == 2
                1
            elseif L == 3
                7
            elseif L == 4
                4
            elseif L == 7
                8
            else
                L1, L4 = length(i ∩ _1), length(i ∩ _4)
                if L == 5
                    if (L1, L4) == (1, 2)
                        2
                    elseif (L1, L4) == (2, 3)
                        3
                    else
                        5
                    end
                else
                    if (L1, L4) == (2, 3)
                        0
                    elseif (L1, L4) == (1, 3)
                        6
                    else
                        9
                    end
                end
            end
            10*n + m
        end
    end
end

const TEST_STRING = """be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce"""

@testset "day08" begin
    @test solve(IOBuffer(TEST_STRING)) == (26, 61229)
end

end # module
