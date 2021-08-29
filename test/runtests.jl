cleanup() = begin
    rm("matrices"; force=true, recursive=true)
    rm("something_or_other_1=0_5_5_7.json"; force=true, recursive=true)
    rm("something_or_other_1=0_5_5_7.mytricks.h5"; force=true, recursive=true)
    rm("something_or_other_1=0_5_5_7.h5"; force=true, recursive=true)
    rm("numbers.dir"; force=true, recursive=true)
    rm("numbers.h5"; force=true, recursive=true)
    rm("stuff.h5"; force=true, recursive=true)
    rm("datafile.h5"; force=true, recursive=true)
end
  
cleanup()
module mt0001
using Test
using DataDrop: clean_file_name, with_extension
function test()
    name = "something or other.1=0.5_5:7"
    s =  clean_file_name(name)
    @test s == "something_or_other_1=0_5_5_7" 
    a = with_extension(s, ".ext")
    @test a == "something_or_other_1=0_5_5_7.ext"
    a = with_extension(s, "ext")
    @test a == "something_or_other_1=0_5_5_7.ext"
    a = with_extension(s * ".dat", "ext")
    @test a == "something_or_other_1=0_5_5_7.ext"
    a = with_extension(s * ".", "ext")
    @test a == "something_or_other_1=0_5_5_7.ext"
    a = with_extension(s * ".x", "ext")
    @test a == "something_or_other_1=0_5_5_7.ext"
    true
end
end
using .mt0001
mt0001.test()

cleanup()
module mt0002
using Test
using DataDrop: clean_file_name, with_extension
using DataDrop: store_json, retrieve_json
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

cleanup()
module mt0003
using Test
using DataDrop: clean_file_name, with_extension
using DataDrop: store_matrix, retrieve_matrix
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

cleanup()
module mt0004
using Test
using DataDrop: clean_file_name, with_extension
using DataDrop: store_matrix, retrieve_matrix
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

cleanup()
module mt0005
using Test
using DataDrop: clean_file_name, with_extension
using DataDrop: store_matrix, retrieve_matrix
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

cleanup()
module mt0006
using Test
using SparseArrays
using DataDrop: clean_file_name, with_extension
using DataDrop: store_matrix, retrieve_matrix
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

cleanup()
module mt0007
using Test
using DataDrop: clean_file_name, with_extension
using DataDrop: store_matrix, retrieve_matrix
function test()
    p = "matrices"
    mkpath(p)
    ext = ""
    for t in [Int, Float32, Float64, Complex{Float64}]
        name = joinpath(p, "matrix B1 " * string(t))
        s = with_extension(clean_file_name(name), ext)
        d = rand(t, 3, 2)
        store_matrix(s, "/mydata/matrices/B1", d)
        @test isfile(s * ".h5") == true
        d1 = retrieve_matrix(s, "/mydata/matrices/B1")
        @test d == d1
    end
    true
end
end
using .mt0007
mt0007.test()

cleanup()
module mt0008
using Test
using SparseArrays
using DataDrop: clean_file_name, with_extension
using DataDrop: store_matrix, retrieve_matrix
function test()
    p = "matrices"
    mkpath(p)
    for t in [Int, Float32, Float64, Complex{Float64}]
        name = joinpath(p, "matrix S" * string(t))
        ext = "h5f"
        s = with_extension(clean_file_name(name), ext)
        d = sprand(t, 5, 3, 0.75)
        store_matrix(s, "/data", d)
        d1 = retrieve_matrix(s, "/data")
        @test d == d1
    end
    true
end
end
using .mt0008
mt0008.test()

cleanup()
module mt0009
using Test
using SparseArrays
using DataDrop: clean_file_name, with_extension, file_extension
using DataDrop: store_matrix, retrieve_matrix
function test()
    p = "matrices.dir"
    @test file_extension(p) == ".dir"
    p = "matrices.h5"
    @test file_extension(p) == ".h5"
    p = "matri.ces.dir"
    @test file_extension(p) == ".dir"
    p = "matrices."
    @test file_extension(p) == "."
    p = "matrices"
    @test file_extension(p) == ""
    true
end
end
using .mt0009
mt0009.test()

cleanup()
module mt0010
using Test
using DataDrop: clean_file_name, with_extension, file_extension
using DataDrop: store_value, retrieve_value
function test()
    p = "numbers.dir"
    a = 3.13
    store_value(p, "a", a)
    ra = retrieve_value(p, "a")
    @test a == ra
    Test.@test_throws ErrorException store_value(p, "/a", a)
    ra = retrieve_value(p, "/a")
    @test a == ra
    store_value(p, "/mynumber/a", a)
    ra = retrieve_value(p, "/mynumber/a")
    @test a == ra
    b = 61
    store_value(p, "/mynumber/b", b)
    rb = retrieve_value(p, "/mynumber/b")
    @test b == rb
    true
end
end
using .mt0010
mt0010.test()

cleanup()
module mt0011
using Test
using DataDrop: clean_file_name, with_extension, file_extension
using DataDrop: store_value, retrieve_value
function test()
    p = "numbers.h5"
    a = 3.13
    store_value(p, "/mynumber/a", a)
    ra = retrieve_value(p, "/mynumber/a")
    @test a == ra
    b = 61
    store_value(p, "/mynumber/b", b)
    rb = retrieve_value(p, "/mynumber/b")
    @test b == rb
    true
end
end
using .mt0011
mt0011.test()

cleanup()
module mt0012
using Test
using DataDrop: clean_file_name, with_extension, file_extension
using DataDrop: store_value, retrieve_value
function test()
    p = "stuff.h5"
    a = 3.13
    store_value(p, "/mynumber/a", a)
    ra = retrieve_value(p, "/mynumber/a")
    @test a == ra
    b = "61"
    store_value(p, "/mystring/b", b)
    rb = retrieve_value(p, "/mystring/b")
    @test b == rb
    true
end
end
using .mt0012
mt0012.test()

cleanup()
module mt0013
using Test
using SparseArrays
using DataDrop: clean_file_name, with_extension
using DataDrop: store_matrix, retrieve_matrix
function test()
    p = "matrices/afile.h5"
    mkpath(p)

    d = rand(Int64, 6, 3)
    store_matrix(joinpath(p, "afile.h5"), "/data/d", d)
    d1 = retrieve_matrix(joinpath(p, "afile.h5"), "/data/d")
    @test d == d1

    b = rand(Float64, 6, 3)
    store_matrix(joinpath(p, "afile.h5"), "/data/b", b)
    b1 = retrieve_matrix(joinpath(p, "afile.h5"), "/data/b")
    @test b == b1

    d1 = retrieve_matrix(joinpath(p, "afile.h5"), "/data/d")
    @test d == d1

    b1 = retrieve_matrix(joinpath(p, "afile.h5"), "/data/b")
    @test b == b1

    true
end
end
using .mt0013
mt0013.test()

cleanup()
module mt0014
using Test
using SparseArrays
using DataDrop: clean_file_name, with_extension
using DataDrop: store_matrix, retrieve_matrix, store_value, retrieve_value
function test()
    p = "matrices/afile.h5"
    mkpath(p)
    f = joinpath(p, "afile.h5")

    d = rand(Int64, 6, 3)
    store_matrix(f, "/data/d", d)
    d1 = retrieve_matrix(f, "/data/d")
    @test d == d1

    b = rand(Float64, 6, 3)
    store_matrix(f, "/data/b", b)
    b1 = retrieve_matrix(f, "/data/b")
    @test b == b1

    d1 = retrieve_matrix(f, "/data/d")
    @test d == d1

    b1 = retrieve_matrix(f, "/data/b")
    @test b == b1

    store_value(f, "name", "afile.h5")
    v = retrieve_value(f, "name")
    @test v == "afile.h5"


    d1 = retrieve_matrix(f, "/data/d")
    @test d == d1

    b1 = retrieve_matrix(f, "/data/b")
    @test b == b1

    true
end
end
using .mt0014
mt0014.test()

cleanup()
module mt0015
using Test
using SparseArrays
using DataDrop: clean_file_name, with_extension
using DataDrop: store_matrix, retrieve_matrix, store_value, retrieve_value
function test()
    
    f = joinpath(".", "datafile.h5")

    d = rand(Int64, 6, 3)
    store_matrix(f, "/data/d", d)
    d1 = retrieve_matrix(f, "/data/d")
    @test d == d1

    b = rand(Float64, 6, 3)
    store_matrix(f, "/data/b", b)
    b1 = retrieve_matrix(f, "/data/b")
    @test b == b1

    d1 = retrieve_matrix(f, "/data/d")
    @test d == d1

    b1 = retrieve_matrix(f, "/data/b")
    @test b == b1

    store_value(f, "name", "afile.h5")
    v = retrieve_value(f, "name")
    @test v == "afile.h5"


    d1 = retrieve_matrix(f, "/data/d")
    @test d == d1

    b1 = retrieve_matrix(f, "/data/b")
    @test b == b1

    true
end
end
using .mt0015
mt0015.test()
cleanup()