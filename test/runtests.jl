rm("matrices"; force=true, recursive=true)
rm("something_or_other_1=0_5_5_7.json"; force=true, recursive=true)
rm("something_or_other_1=0_5_5_7.mytricks.h5"; force=true, recursive=true)
rm("something_or_other_1=0_5_5_7.h5"; force=true, recursive=true)
  
module mt0001
using Test
using DataValet: clean_file_name, with_extension
function test()
    name = "something or other.1=0.5_5:7"
    s =  clean_file_name(name)
    @test s == "something_or_other_1=0_5_5_7" 
    a = with_extension(s, ".ext")
    @test a == "something_or_other_1=0_5_5_7.ext"
    a = with_extension(s, "ext")
    @test a == "something_or_other_1=0_5_5_7.ext"
    true
end
end
using .mt0001
mt0001.test()

module mt0002
using Test
using DataValet: clean_file_name, with_extension
using DataValet: store_json, retrieve_json
function test()
    name = "something or other.1=0.5_5:7"
    ext = ".json"
    s =  clean_file_name(name)
    @test s == "something_or_other_1=0_5_5_7" 
    a = with_extension(s, ext)
    d = Dict("name" => a, "b" => 1, "c" => [3, 1, 3])
    store_json(a, d)
    d1 = retrieve_json(a)
    @test d == d1
    true
end
end
using .mt0002
mt0002.test()

module mt0003
using Test
using DataValet: clean_file_name, with_extension
using DataValet: store_matrix, retrieve_matrix
function test()
    name = "something.or.other.1=0.5_5:7"
    ext = ""
    s =  clean_file_name(name)
    @test s == "something_or_other_1=0_5_5_7"
    a = with_extension(s, ext)
    d = rand(3, 2)
    store_matrix(a, d)
    d1 = retrieve_matrix(a)
    @test d == d1
    true
end
end
using .mt0003
mt0003.test()

module mt0004
using Test
using DataValet: clean_file_name, with_extension
using DataValet: store_matrix, retrieve_matrix
function test()
    p = "matrices"
    mkpath(p)
    name = joinpath(p, "matrix d")
    ext = ""
    s = with_extension(clean_file_name(name), ext)
    d = rand(3, 2)
    store_matrix(s, d)
    d1 = retrieve_matrix(s)
    @test d == d1
    true
end
end
using .mt0004
mt0004.test()


module mt0005
using Test
using DataValet: clean_file_name, with_extension
using DataValet: store_matrix, retrieve_matrix
function test()
    p = "matrices"
    mkpath(p)
    ext = ""
    for t in [Int, Float32, Float64, Complex{Float64}]
        name = joinpath(p, "matrix d " * string(t))
        s = with_extension(clean_file_name(name), ext)
        d = rand(t, 3, 2)
        store_matrix(s, d)
        @test isfile(s * ".h5") == true
        d1 = retrieve_matrix(s)
        @test d == d1
    end
    true
end
end
using .mt0005
mt0005.test()


module mt0006
using Test
using SparseArrays
using DataValet: clean_file_name, with_extension
using DataValet: store_matrix, retrieve_matrix
function test()
    p = "matrices"
    mkpath(p)
    name = joinpath(p, "matrix d")
    ext = ""
    s = with_extension(clean_file_name(name), ext)
    d = sprand(Float64, 5, 3, 0.75)
    store_matrix(s, d)
    d1 = retrieve_matrix(s)
    @test d == d1
    true
end
end
using .mt0006
mt0006.test()



