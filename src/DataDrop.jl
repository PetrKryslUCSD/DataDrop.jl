module DataDrop

using JSON
using SparseArrays
using HDF5
using LinearAlgebra

const _sep = "-"

"""
    clean_file_name(name)

Construct a clean file name.

Replace '.', ':', ' ' (dot, colon, space) with underscores.

Example:
```
s =  clean_file_name("something or other.1=0.5_5:7")
s == "something_or_other_1=0_5_5_7"
```
"""
function clean_file_name(name)
    cleanname = replace(replace(replace(name,'.'=>'_'),':'=>'_'),' '=>'_')    
    return cleanname
end

"""
    file_extension(filename)

Extract extension from the string representing a file name.

Expected result:
```
p = "matrices.dir"
file_extension(p) == ".dir"
p = "matrices.h5"
file_extension(p) == ".h5"
p = "matri.ces.dir"
file_extension(p) == ".dir"
p = "matrices."
file_extension(p) == "."
p = "matrices"
file_extension(p) == ""
```
"""
function file_extension(filename)
    _, e = splitext(filename)
    return e
end

"""
    with_extension(filename, ext)

Make sure the file name has the desired extension.

`ext` can be either with or without the leading dot. 

```
with_extension("fo_1=0_5_5_7", ".ext") == "fo_1=0_5_5_7.ext"
with_extension("fo_1=0_5_5_7", "ext") == "fo_1=0_5_5_7.ext"  
with_extension("fo_1=0_5_5_7.dat", "ext") == "fo_1=0_5_5_7.ext"  
```
"""
function with_extension(filename, ext)
    if ext == ""
        # Remove the extension completely
        f, e = splitext(filename)
        return f 
    else        
        # If the file has the wrong extension, remove it
        f, e = splitext(filename)
        # Replace or fix up the extension
        if ext[1] == '.'
            ext = ext[2:end]
        end
        if match(Regex(".*\\." * ext * "\$"), f) === nothing
            f = f * "." * ext
        end
        return f
    end
end

"""
    retrieve_json(j)

Retrieve a dictionary from a JSON file named `j`.

Example:
```
d = retrieve_json("myfile.json")
```
"""
function retrieve_json(j)
    j = with_extension(j, "json")
    return open(j, "r") do file
        JSON.parse(file)
    end
end

"""
    store_json(j, d)

Store a dictionary `d` into a JSON file named `j`.

The dictionary is stored into a JSON file. If the file name `fname` is supplied
without an extension, it is appended the ".json" extension.
"""
function store_json(j, d)
    j = with_extension(j, "json")
    open(j, "w") do file
        JSON.print(file, d, 4)
    end
end

const MATRIX_UNKNOWN = -1
const MATRIX_DENSE = 0
const MATRIX_SPARSE = 1

"""
    retrieve_matrix(fname)

Retrieve a matrix from file `fname`.
"""
function retrieve_matrix(fname)
    return retrieve_matrix(fname, "")
end

"""
    empty_hdf5_file(fname)

Empty an HDF5 file. All contents will be erased.
"""
function empty_hdf5_file(fname)
    # If the file exists, delete all contents
    if file_extension(fname) == ""
        fname = with_extension(fname, "h5")
    end
    h5open(fname, "w") do _
    end
end

"""
    retrieve_matrix(fname, mpath)

Retrieve a matrix from file `fname`.

The matrix data is stored under the path `mpath`.

Example:
Storing a sparse matrix as "/data" with
`store_matrix("test/matrices/matrix_SInt64.h5f", "/data", d)` gives:
```
julia> f = h5open("test/matrices/matrix_SInt64.h5f", "r")      
�
└─ � data 
   ├─ � I 
   ├─ � J 
   ├─ � V 
   ├─ � matrix_type
   ├─ � ncols      
   └─ � nrows   
```  

Example:
Storing a dense matrix under the default path ("/") with
`store_matrix("matrix_d_Float32.h5", d)` gives:
```
julia> f = h5open("matrix_d_Float32.h5", "r")            
�  
├─ � matrix      
└─ � matrix_type    
```
"""
function retrieve_matrix(fname, mpath)
    if file_extension(fname) == "" 
        fname = with_extension(fname, "h5")
    end
    if mpath != "" && mpath[end:end] != "/"
        mpath = mpath * "/"
    end
    typ = MATRIX_UNKNOWN
    return h5open(fname, "r") do f
        typ = read(f, mpath * "matrix_type")
        if typ == MATRIX_DENSE
            v = read(f, mpath * "matrix")
        elseif typ == MATRIX_SPARSE
            I = read(f, mpath * "I")
            J = read(f, mpath * "J")
            V = read(f, mpath * "V")
            nrows = read(f, mpath * "nrows")
            ncols = read(f, mpath * "ncols")
            v = sparse(I, J, V, nrows, ncols)
        end
        v
    end
end

"""
    store_matrix(fname, matrix)

Store a dense matrix into the file named `fname`.
"""
function store_matrix(fname, matrix)
    store_matrix(fname, "", matrix)
end

# In order to handle transpose and adjoint, we need additional methods
# These methods materialize the transposes/adjoints using Matrix
store_matrix(fname, matrix::LinearAlgebra.Adjoint{T, Matrix{T}}) where {T} = 
    store_matrix(fname, "", Matrix(matrix))

store_matrix(fname, mpath, matrix::LinearAlgebra.Adjoint{T, Matrix{T}}) where {T} = store_matrix(fname, mpath, Matrix(matrix))

store_matrix(fname, matrix::LinearAlgebra.Transpose{T, Matrix{T}}) where {T} = 
    store_matrix(fname, "", Matrix(matrix))

store_matrix(fname, mpath, matrix::LinearAlgebra.Transpose{T, Matrix{T}}) where {T} = store_matrix(fname, mpath, Matrix(matrix))

"""
    store_matrix(fname, mpath, matrix)

Store a dense matrix under the path `mpath` into the file `fname`.
"""
function store_matrix(fname, mpath, matrix)
    if file_extension(fname) == ""
        fname = with_extension(fname, "h5")
    end
    if mpath != "" && mpath[end:end] != "/"
        mpath = mpath * "/"
    end
    h5open(fname, "cw") do file
        write(file, mpath * "matrix_type", MATRIX_DENSE) 
        write(file, mpath * "matrix", matrix) 
    end
end

"""
    store_matrix(fname, mpath, matrix::SparseArrays.SparseMatrixCSC{T, Int64}) where {T}

Store a sparse matrix under the path `mpath` into the file named `fname`.

The matrix is stored into an HDF5 file. If the file name `fname` is supplied
without an extension, it is appended the ".h5" extension.
"""
function store_matrix(fname, mpath, matrix::SparseArrays.SparseMatrixCSC{T, Int64}) where {T}
    I, J, V = findnz(matrix)
    if file_extension(fname) == ""
        fname = with_extension(fname, "h5")
    end
    if mpath != "" && mpath[end:end] != "/"
        mpath = mpath * "/"
    end
    h5open(fname, "cw") do file
        write(file, mpath * "matrix_type", MATRIX_SPARSE) 
        write(file, mpath * "I", I) 
        write(file, mpath * "J", J) 
        write(file, mpath * "V", V) 
        write(file, mpath * "nrows", size(matrix, 1)) 
        write(file, mpath * "ncols", size(matrix, 2)) 
    end
end

"""
    store_matrix(fname, matrix::SparseArrays.SparseMatrixCSC{T, Int64}) where {T}

Store a sparse matrix into the file named `fname`.

The matrix is stored into an HDF5 file. If the file name `fname` is supplied
without an extension, it is appended the ".h5" extension.
"""
function store_matrix(fname, matrix::SparseArrays.SparseMatrixCSC{T, Int64}) where {T}
    store_matrix(fname, "", matrix)
end

"""
    store_value(fname, vpath, num) 

Store a number or a string into the file named `fname` under the name `vpath`.
"""
function store_value(fname, vpath, num) 
    if file_extension(fname) == ""
        fname = with_extension(fname, "h5")
    end
    if vpath == ""
        vpath = "number"
    end
    if vpath != "" && vpath[end:end] != "/"
        vpath = vpath * "/"
    end

    h5open(fname, "cw") do file
        write(file, vpath, num) 
    end
end


"""
    retrieve_value(fname, vpath)

Retrieve a number or a string known as `vpath` from the file named `fname`.
"""
function retrieve_value(fname, vpath)
    if file_extension(fname) == "" 
        fname = with_extension(fname, "h5")
    end
    if vpath != "" && vpath[end:end] != "/"
        vpath = vpath * "/"
    end
    return h5open(fname, "r") do f
        v = read(f, vpath)
        v
    end
end

end # module
