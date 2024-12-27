using Test
using Lexbor
using AbstractTrees

@testset "Lexbor" begin
    fixtures = joinpath(@__DIR__, "fixtures")

    let doc = open(Lexbor.Document, joinpath(fixtures, "30_input.html"))
        bq = only(Lexbor.find_all_nodes("blockquote", doc))
        @test bq.attributes == ["class" => "search_headline"]

        p = first(Lexbor.find_all_nodes("p", doc))
        @test p.attributes == ["class" => "repo-description"]
    end
    let doc = open(Lexbor.Document, joinpath(fixtures, "example.html"))
        meta = only(Lexbor.find_all_nodes("meta", doc))
        @test meta.attributes == ["description" => "test page"]
    end
    let doc = open(Lexbor.Document, joinpath(fixtures, "multitext_input.html"))
        strong = only(Lexbor.find_all_nodes("strong", doc))
        @test strong.children == ["b"]
    end
    let doc = open(Lexbor.Document, joinpath(fixtures, "template_input.html"))
        n = only(Lexbor.find_all_nodes("template", doc))
        @test n.attributes == ["v-slot:avatar" => nothing]
    end
    let doc = open(Lexbor.Document, joinpath(fixtures, "varied_input.html"))
        n = only(Lexbor.find_all_nodes("input", doc))
        @test n.attributes == ["type" => "name", "value" => "abc"]
    end
    let doc = open(Lexbor.Document, joinpath(fixtures, "whitespace_input.html"))
        n = only(Lexbor.find_all_nodes("code", doc))
        @test n.children == ["\nfoo\nbar\nbaz\n        "]
    end
    let doc = open(Lexbor.Document, joinpath(fixtures, "document-large.html"))
        n = only(Lexbor.find_all_nodes("title", doc))
        @test n.children == ["HTML Standard"]
        nodes = collect(AbstractTrees.PreOrderDFS(doc.root))
        @test length(nodes) == 25396
        @test contains(last(nodes), "see also https://www.w3.org/Bugs/Public")
    end
end
