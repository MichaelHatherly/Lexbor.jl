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

    let doc = Lexbor.Document("""<div id="ok"><span>test</span></div>""")
        nodes_all = Lexbor.query(doc, """div, div[id="ok"], div:has(:not(a))""")
        nodes_first =
            Lexbor.query(doc, """div, div[id="ok"], div:has(:not(a))"""; first = true)
        @test length(nodes_all) == 3
        @test length(nodes_first) == 1

        node = only(nodes_first)
        div_node = Lexbor.query(node, "div")
        @test isempty(div_node)
        div_node = Lexbor.query(node, "div"; root = true)
        @test !isempty(div_node)
        @test node == only(div_node)

        function get_div(doc, selector)
            matcher = Lexbor.Matcher(selector)
            for node in AbstractTrees.PreOrderDFS(Node(doc))
                matcher(node) && return node
            end
            return nothing
        end

        @test get_div(doc, "div#ok") === node
        @test Lexbor.tag(get_div(doc, "span")) === :span
    end

    @testset "serialization" begin
        let doc = Lexbor.Document("""<div id="ok"><span>test</span><br></div>""")
            div = only(Lexbor.query(doc, "div"))
            @test Lexbor.outer_html(div) == """<div id="ok"><span>test</span><br></div>"""
            @test Lexbor.inner_html(div) == """<span>test</span><br>"""

            br = only(Lexbor.query(doc, "br"))
            @test Lexbor.inner_html(br) == ""

            span = only(Lexbor.query(doc, "span"))
            textnode = first(span)
            @test Lexbor.is_text(textnode)
            @test Lexbor.outer_html(textnode) == "test"
            @test Lexbor.inner_html(textnode) == ""
        end

        let doc = Lexbor.Document("<p>a &amp; b &lt; c</p>")
            textnode = first(only(Lexbor.query(doc, "p")))
            @test Lexbor.outer_html(textnode) == "a &amp; b &lt; c"
        end

        let doc = Lexbor.Document("""<div id="ok"><span>test</span></div>""")
            expected = "<html><head></head><body><div id=\"ok\"><span>test</span></div></body></html>"
            @test Lexbor.outer_html(doc) == expected
            @test Lexbor.inner_html(doc) == expected

            reparsed = Lexbor.Document(Lexbor.outer_html(doc))
            div = only(Lexbor.query(reparsed, "div"))
            @test Lexbor.attributes(div) == Dict("id" => "ok")
            @test Lexbor.text(first(only(Lexbor.query(reparsed, "span")))) == "test"
        end

        let html = let doc = Lexbor.Document("""<div id="ok"><span>test</span></div>""")
                Lexbor.outer_html(doc)
            end
            GC.gc()
            @test html == "<html><head></head><body><div id=\"ok\"><span>test</span></div></body></html>"
        end
    end

    @testset "navigation" begin
        let doc = Lexbor.Document("""<div id="ok"><span>a</span><b>b</b></div>""")
            div = only(Lexbor.query(doc, "div"))
            span = only(Lexbor.query(doc, "span"))
            b = only(Lexbor.query(doc, "b"))

            @test Lexbor.parent_node(span) == div
            @test Lexbor.tag(Lexbor.parent_node(span)) === :div
            @test Lexbor.parent_node(Lexbor.Node(doc)) === nothing

            @test Lexbor.next_sibling(span) == b
            @test Lexbor.next_sibling(b) === nothing

            @test Lexbor.prev_sibling(b) == span
            @test Lexbor.prev_sibling(span) === nothing

            @test Lexbor.last_child(div) == b
            @test Lexbor.is_text(Lexbor.last_child(span))
            @test Lexbor.text(Lexbor.last_child(span)) == "a"
        end

        let doc = Lexbor.Document("<p></p>")
            p = only(Lexbor.query(doc, "p"))
            @test Lexbor.last_child(p) === nothing
        end
    end

    @testset "attribute lookup" begin
        let doc = Lexbor.Document("""<div id="ok"><span>test</span></div>""")
            div = only(Lexbor.query(doc, "div"))
            @test Lexbor.attribute(div, "id") == "ok"
            @test Lexbor.attribute(div, "missing") === nothing
            @test Lexbor.has_attribute(div, "id") === true
            @test Lexbor.has_attribute(div, "missing") === false

            span = only(Lexbor.query(doc, "span"))
            textnode = first(span)
            @test Lexbor.is_text(textnode)
            @test Lexbor.attribute(textnode, "x") === nothing
            @test Lexbor.has_attribute(textnode, "x") === false
        end

        let doc = open(Lexbor.Document, joinpath(fixtures, "template_input.html"))
            n = only(Lexbor.query(doc, "template"))
            @test Lexbor.attribute(n, "v-slot:avatar") === nothing
            @test Lexbor.has_attribute(n, "v-slot:avatar") === true
        end
    end

    @testset "document accessors" begin
        let doc = open(Lexbor.Document, joinpath(fixtures, "document-large.html"))
            @test Lexbor.title(doc) == "HTML Standard"
        end

        let doc = Lexbor.Document("<p>x</p>")
            @test Lexbor.title(doc) === nothing
        end

        let doc = Lexbor.Document("""<div id="ok"><span>test</span></div>""")
            @test Lexbor.tag(Lexbor.head(doc)) === :head
            @test Lexbor.tag(Lexbor.body(doc)) === :body

            div_from_body = only(Lexbor.query(Lexbor.body(doc), "div"))
            div_from_doc = only(Lexbor.query(doc, "div"))
            @test div_from_body == div_from_doc
        end
    end
end
