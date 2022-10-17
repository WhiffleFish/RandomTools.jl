function path2csv(path::AbstractString)
    split_path = split(path, '.')
    split_path[end] = "csv"
    return join(split_path,'.')
end

function process_timed_imports(in_path::AbstractString, out_path=path2csv(in_path))
    lines = readlines(in_path)
    stripped_lines = map(split.(lines, " ms ")) do v
        v′ = strip.(v)
        v′[2] = first(split(v′[2]))
        v′
    end
    sort!(stripped_lines, rev=true, by=v->parse(Float64, v[1]))
    csv_vals = join(join.(stripped_lines, ", "), '\n')
    final_str = "time(ms), package\n"*csv_vals
    open(out_path, "w") do f
        write(f, final_str)
    end
end

# _path = abspath(joinpath(@__DIR__, "..", "test", "time_imports.txt"))
# isfile(_path)
# process_timed_imports(_path)
