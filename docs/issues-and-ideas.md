
Issues and ideas:

-- Documenter:
using DataDrop
import Pkg; Pkg.add("DocumenterTools")
using DocumenterTools
Travis.genkeys(user="PetrKryslUCSD", repo="https://github.com/PetrKryslUCSD/DataDrop.jl")
Pkg.rm("DocumenterTools")

- Transformation matrix for an element should be calculated just once at the beginning of the integration for each element. The transformation then needs to be applied when the integration loop is finished.
- Use averaging for the transverse sheer strain-displacement matrix.


