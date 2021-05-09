# import markovify
markovify = pyimport("markovify")

"""
    generate(corpusfile::String, modelfile::String, size = 3)

Generate a Markov chain model.
"""
function generate(corpusfile::String, modelfile::String, size = 3)
    # import corpus
    corpus = read(open(corpusfile, "r"), String)
    # generate model
    model = markovify.NewlineText(corpus, size)
    # export json
    modeljson = model.to_json()
    open(modelfile, "w") do io
        write(io, modeljson)
    end
    return model
end

"""
    reconstruct(modelsdir::Vector{String})

Reconstruct the Markov chain model.
"""
function reconstruct(modelsdir::Vector{String})
    # reconstruct model
    models = Vector{PyObject}()
    for modelfile in modelsdir
        modeljson = read(open(modelfile, "r"), String)
        push!(models, markovify.NewlineText.from_json(modeljson))
    end
    # generate new model
    return markovify.combine(models)
end

"""
    makesentence() -> String

Generate a Japanese sentence of 140 characters or less from a Markov chain model stored in json format.
Does not tweet at run time.

# Examples
```julia-repl
julia> makesentence()
"TL見ながらなかなかエンジンのかからない車みたいに笑ってしまったので今月は生き延びれそう"
```
"""
function makesentence()
    modelsdir = readdir("data/models", join = true)
    s = reconstruct(modelsdir).make_short_sentence(140)
    return s |> rpl(" " => "")
end