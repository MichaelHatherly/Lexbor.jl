using Documenter
using Lexbor

makedocs(sitename = "Lexbor", format = Documenter.HTML(), modules = [Lexbor])

deploydocs(repo = "github.com/MichaelHatherly/Lexbor.jl.git", push_preview = true)
