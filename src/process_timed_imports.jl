const IMPORT_RE = r"^\s{0,}\d{1,}\.\d ms  \S{2,}"


# This code is god-awful and needs to be cleaned up
macro store_timed_imports(ex)
    @assert ex.head === :using
    pkgname = string(ex.args[1].args[1])
    return quote
        original_stdout = stdout
        rd, wr = redirect_stdout()
        InteractiveUtils.@time_imports $ex
        redirect_stdout(original_stdout)
        close(wr)
        s = read(rd, String)
        final_str = process_io_str(s)
        pretty_csv_print(final_str)
        fname = abspath(joinpath(pwd(), "$($pkgname)_timed_imports.csv"))
        open(fname, "w") do f
            write(f, final_str)
        end
        nothing
    end
end

function pretty_csv_print(csv_str)
    lines = split(csv_str, '\n')
    for line ∈ lines
        println(replace(line, "," =>"\t"))
    end
    nothing
end

function path2csv(path::AbstractString)
    split_path = split(path, '.')
    split_path[end] = "csv"
    return join(split_path,'.')
end

function process_io_str(str::AbstractString)
    lines = split(str, '\n')
    valid_lines = falses(length(lines))
    for i ∈ eachindex(lines)
        valid_lines[i] = !isnothing(match(IMPORT_RE, lines[i]))
    end
    lines = lines[valid_lines]
    stripped_lines = map(split.(lines, " ms ")) do v
        v′ = strip.(v)
        v′[2] = first(split(v′[2]))
        v′
    end
    sort!(stripped_lines, rev=true, by=v->parse(Float64, v[1]))
    csv_vals = join(join.(stripped_lines, ", "), '\n')
    final_str = "time(ms), package\n"*csv_vals
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
