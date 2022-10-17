const PATH_RE = r"^\[\[\".*\"\]\]$"
const DATE_RE = r"time = \d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ"

function check_manifest(path)
    @assert isfile(path)
    f = open(path)
    s = String(read(f))
    close(f)

    split_s = split(s, "\n")
    isempty(last(split_s)) && pop!(split_s)

    for i ∈ 1:2:length(split_s)
        path = split_s[i]
        time = split_s[i+1]

        match_path = match(PATH_RE, path)
        match_time = match(DATE_RE, time)

        if isnothing(match_path) || isnothing(match_time)
            @info """
                error on line $i
                $path
                $time
            """
            break
        end
    end
    println("No errors")
end

# _path = "/Users/tyler/Downloads/manifest_usage.toml"
# match(path_re, "[[\"$path\"]]")
# check_manifest(_path)
