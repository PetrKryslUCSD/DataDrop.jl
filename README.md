[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Build status](https://github.com/PetrKryslUCSD/DataDrop.jl/workflows/CI/badge.svg)](https://github.com/PetrKryslUCSD/DataDrop.jl/actions)
[![codecov](https://codecov.io/gh/PetrKryslUCSD/DataDrop.jl/branch/master/graph/badge.svg)](https://app.codecov.io/gh/PetrKryslUCSD/DataDrop.jl)
[![Latest documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://petrkryslucsd.github.io/DataDrop.jl/dev)

# DataDrop.jl

Simple package for storing data to the disk:

- Store and retrieve matrices, both dense and sparse, and number and string scalar values, using the HDF5 machine-independent binary format.

- Store and retrieve dictionaries of values using the JSON format.

To store and retrieve matrix data is as simple as
```
julia> using DataDrop
   
julia> using SparseArrays  
   
julia> c = sprand(4, 3, 0.5)     
4×3 SparseMatrixCSC{Float64, Int64} with 5 stored entries:     
  ⋅   ⋅   0.780225   
  ⋅  0.0612236   ⋅   
  ⋅   ⋅    ⋅   
 0.262007  0.778962   0.0651033  
   
julia> DataDrop.store_matrix("c.h5", c)   
   
julia> yac = DataDrop.retrieve_matrix("c.h5")   
4×3 SparseMatrixCSC{Float64, Int64} with 5 stored entries:     
  ⋅   ⋅   0.780225   
  ⋅  0.0612236   ⋅   
  ⋅   ⋅    ⋅   
 0.262007  0.778962   0.0651033  
```

To store a numerical value or a string, use
```
julia> DataDrop.store_value("numbers.h5", "/mynumber/a", a)  

julia> DataDrop.retrieve_value("numbers.h5", "/mynumber/a")              
42
``` 

To store a dictionary of values, we can do
```
julia> s = "variable-a=0.5:b=5:c=7"
"variable-a=0.5:b=5:c=7"                                             
                        
julia> s =  DataDrop.clean_file_name(s) 
"variable-a=0_5_b=5_c=7"
                
julia> a = DataDrop.with_extension(s, "json")
"variable-a=0_5_b=5_c=7.json"

julia> d = Dict("name" => a, "b" => 1, "c" => [3, 1, 3])        
Dict{String, Any} with 3 entries: 
  "name" => "variable-a=0_5_b=5_c=7.json" 
  "c"    => [3, 1, 3]
  "b"    => 1

julia> DataDrop.store_json(a, d)

julia> d1 = DataDrop.retrieve_json(a)
Dict{String, Any} with 3 entries:
  "name" => "variable-a=0_5_b=5_c=7.json"
  "c"    => Any[3, 1, 3]
  "b"    => 1         

julia> 
```
