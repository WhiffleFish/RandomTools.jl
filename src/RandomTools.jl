module RandomTools

using InteractiveUtils

include("manifest_fix.jl")
export check_manifest

include("process_timed_imports.jl")
export @store_timed_imports


end # module RandomTools
