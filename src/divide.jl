# import SudachiPy
tokenizer = pyimport("sudachipy.tokenizer")
dictionary = pyimport("sudachipy.dictionary")

"""currying `replace` function"""
rpl(pat_f::Pair) = s -> replace(s, pat_f)

"""
    preprocess(sentence::AbstractString) -> AbstractString

Remove URLs, hashtags, @username, and consecutive spaces.
Decode `&`, `<`, `>`, `\n`, and `"`.
"""
function preprocess(sentence::AbstractString)
    return sentence |>
        rpl(r"https?://[\w/:%#\$&\?\(\)~\.=\+\-]+" => " ") |>
        rpl(r"#" => " ") |>
        rpl(r"\(@[A-Za-z0-9_]{1,15} *\)" => " ") |>
        rpl(r"@[A-Za-z0-9_]{1,15}" => " ") |>
        rpl("&amp;" => "&") |>
        rpl("&lt;" => "<") |>
        rpl("&gt;" => ">") |>
        rpl("\\n" => "\n") |>
        rpl("\\\"" => "\"") |>
        rpl(r"[ 　]+" => " ")
end

"""
    devide(sentence::AbstractString)

Separate words in Japanese with spaces.
"""
function divide(sentence::AbstractString)
    # create tokenizer object
    tokenizerobj = dictionary.Dictionary().create()
    # split mode: C
    mode = tokenizer.Tokenizer.SplitMode.C
    vec = [m.surface() for m in tokenizerobj.tokenize(sentence, mode)]
    return join(vec, " ")
end
