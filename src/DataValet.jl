module DataValet

using JSON
using SparseArrays
using HDF5

const _sep = "-"

"""
    clean_file_name(name)

Construct a clean file name.
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
    f, e = splitext(filename)
    return e
end

"""
    with_extension(filename, ext)

Make sure the file name has an extension.

`ext` can be either with or without the leading dot.
```
a = with_extension(s, ".ext") = "something_or_other_1=0_5_5_7.ext"
a = with_extension(s, "ext") = "something_or_other_1=0_5_5_7.ext"  
```
"""
function with_extension(filename, ext)
    if ext == ""
        # Remove the extension completely
        f, e = splitext(filename)
        return f 
    else        
        # Replace or fix up the extension
        if ext[1] == '.'
            ext = ext[2:end]
        end
        if match(Regex(".*\\." * ext * "\$"), filename) == nothing
            filename = filename * "." * ext
        end
    end
    return filename
end

"""
    retrieve_json(j)

Retrieve a dictionary from a JSON file.
"""
function retrieve_json(j)
    j = with_extension(j, "json")
    return open(j, "r") do file
        JSON.parse(file)
    end
end

"""
    store_json(j, d)

Store a dictionary into a JSON file.
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
    f = try
        h5open(fname, "r") 
    catch SystemError
        nothing
    end
    typ = read(f, mpath * "matrix_type")
    if typ == MATRIX_DENSE
        return read(f, mpath * "matrix")
    elseif typ == MATRIX_SPARSE
        I = read(f, mpath * "I")
        J = read(f, mpath * "J")
        V = read(f, mpath * "V")
        nrows = read(f, mpath * "nrows")
        ncols = read(f, mpath * "ncols")
        return sparse(I, J, V, nrows, ncols)
    end
    return nothing
end

"""
    store_matrix(fname, matrix)

Store a dense matrix into the file `fname`.
"""
function store_matrix(fname, matrix)
    store_matrix(fname, "", matrix)
end


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
    h5open(fname, "w") do file
        write(file, mpath * "matrix_type", MATRIX_DENSE) 
        write(file, mpath * "matrix", matrix) 
    end
end

"""
    store_matrix(fname, mpath, matrix::SparseArrays.SparseMatrixCSC{T, Int64}) where {T}

Store a sparse matrix under the path `mpath` into the file `fname`.
"""
function store_matrix(fname, mpath, matrix::SparseArrays.SparseMatrixCSC{T, Int64}) where {T}
    I, J, V = findnz(matrix)
    if file_extension(fname) == ""
        fname = with_extension(fname, "h5")
    end
    if mpath != "" && mpath[end:end] != "/"
        mpath = mpath * "/"
    end
    h5open(fname, "w") do file
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

Store a sparse matrix into the file `fname`.
"""
function store_matrix(fname, matrix::SparseArrays.SparseMatrixCSC{T, Int64}) where {T}
    store_matrix(fname, "", matrix)
end

end # module
