using Test
using Lexbor
using AbstractTrees

@testset "Lexbor" begin
    fixtures = joinpath(@__DIR__, "fixtures")

    let doc = open(Lexbor.Document, joinpath(fixtures, "30_input.html"))
        bq = only(Lexbor.query(doc, "blockquote"))
        @test Lexbor.attributes(bq) == Dict("class" => "search_headline")

        p = first(Lexbor.query(doc, "p"))
        @test Lexbor.attributes(p) == Dict("class" => "repo-description")
    end
    let doc = open(Lexbor.Document, joinpath(fixtures, "example.html"))
        meta = only(Lexbor.query(doc, "meta"))
        @test Lexbor.attributes(meta) == Dict("description" => "test page")
    end
    let doc = open(Lexbor.Document, joinpath(fixtures, "multitext_input.html"))
        strong = only(Lexbor.query(doc, "strong"))
        @test Lexbor.text.(AbstractTrees.children(strong)) == ["b"]
    end
    let doc = open(Lexbor.Document, joinpath(fixtures, "template_input.html"))
        n = only(Lexbor.query(doc, "template"))
        @test Lexbor.attributes(n) == Dict("v-slot:avatar" => nothing)
    end
    let doc = open(Lexbor.Document, joinpath(fixtures, "varied_input.html"))
        n = only(Lexbor.query(doc, "input"))
        @test Lexbor.attributes(n) == Dict("type" => "name", "value" => "abc")
    end
    let doc = open(Lexbor.Document, joinpath(fixtures, "whitespace_input.html"))
        n = only(Lexbor.query(doc, "code"))
        @test Lexbor.text.(AbstractTrees.children(n)) == ["\nfoo\nbar\nbaz\n        "]
    end
    let doc = open(Lexbor.Document, joinpath(fixtures, "document-large.html"))
        n = only(Lexbor.query(doc, "title"))
        @test Lexbor.text.(AbstractTrees.children(n)) == ["HTML Standard"]
        nodes = collect(AbstractTrees.PreOrderDFS(Lexbor.Node(doc)))
        @test length(nodes) == 29470
        @test contains(
            Lexbor.comment(last(nodes)),
            "see also https://www.w3.org/Bugs/Public",
        )

        is_tag = Ref(true)
        Lexbor.query(doc, "a") do node
            is_tag[] &= Lexbor.tag(node) === :a
        end
        @test is_tag[]
    end
end
