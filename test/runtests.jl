using Test
using Lexbor
using AbstractTrees

@testset "Lexbor" begin
    fixtures = joinpath(@__DIR__, "fixtures")

    @testset "public interface" begin
        @test Set(filter(n -> Base.isexported(Lexbor, n), names(Lexbor))) == Set([
            :Lexbor,
            :Document,
            :Matcher,
            :Node,
            :Tree,
            :attributes,
            :comment,
            :is_comment,
            :is_element,
            :is_text,
            :query,
            :tag,
            :text,
        ])
        if VERSION >= v"1.11"
            @test Base.ispublic(Lexbor, :append_child!)
            @test Base.ispublic(Lexbor, :outer_html)
            @test Base.ispublic(Lexbor, :text_content)
            @test Base.ispublic(Lexbor, :replace_node!)
            @test !Base.ispublic(Lexbor, :_insert)
        end
    end

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

    @testset "AbstractTrees interface" begin
        let doc = Lexbor.Document("""<div id="ok"><span>a</span><b>b</b></div>""")
            root = Lexbor.Node(doc)
            div = only(Lexbor.query(doc, "div"))
            span = only(Lexbor.query(doc, "span"))
            b = only(Lexbor.query(doc, "b"))

            @test AbstractTrees.ParentLinks(Lexbor.Node) === AbstractTrees.StoredParents()

            @test AbstractTrees.parent(span) == div
            @test AbstractTrees.parent(root) === nothing
            @test AbstractTrees.nextsibling(span) == b
            @test AbstractTrees.nextsibling(b) === nothing
            @test AbstractTrees.prevsibling(b) == span
            @test AbstractTrees.prevsibling(span) === nothing

            @test AbstractTrees.getroot(span) == root
            @test AbstractTrees.isroot(root)
            @test !AbstractTrees.isroot(span)
            @test AbstractTrees.isdescendant(span, root)
            @test !AbstractTrees.isdescendant(root, span)
        end

        let doc = Lexbor.Document("""<div id="a"><i>1</i></div><div id="b"><b>2</b></div>""")
            a = only(Lexbor.query(doc, "div#a"))
            @test string.(AbstractTrees.PreOrderDFS(a)) == ["<div>", "<i>", "\"1\""]
            @test string.(AbstractTrees.PostOrderDFS(a)) == ["\"1\"", "<i>", "<div>"]
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

        let doc = Lexbor.Document("<p>x</p>")
            html = Lexbor.document_element(doc)
            @test Lexbor.tag(html) === :html
            @test Lexbor.parent_node(Lexbor.body(doc)) == html
        end

        let doc = Lexbor.Document("<title> a \n\t b  </title>")
            @test Lexbor.title(doc) == "a b"
        end

        let doc = Lexbor.Document("<title></title>")
            @test Lexbor.title(doc) == ""
        end

        let doc = Lexbor.Document("<frameset></frameset>")
            @test Lexbor.tag(Lexbor.body(doc)) === :frameset
        end
    end

    @testset "accessors follow tree changes" begin
        let doc = Lexbor.Document("<p>old</p>")
            root = Lexbor.document_element(doc)
            old_body = Lexbor.body(doc)
            Lexbor.remove!(old_body)
            @test Lexbor.body(doc) === nothing
            Lexbor.append_child!(root, Lexbor.create_element(doc, :body))
            @test Lexbor.body(doc) != old_body
            @test Lexbor.parent_node(Lexbor.body(doc)) == root

            Lexbor.remove!(Lexbor.head(doc))
            @test Lexbor.head(doc) === nothing

            Lexbor.remove!(root)
            @test Lexbor.document_element(doc) === nothing
            @test Lexbor.body(doc) === nothing
            @test Lexbor.head(doc) === nothing
            @test Lexbor.title(doc) === nothing
        end

        let doc = Lexbor.Document("<title>x</title>")
            title_el = only(Lexbor.query(doc, "title"))
            Lexbor.remove!(title_el)
            @test Lexbor.title(doc) === nothing
        end
    end

    @testset "text content" begin
        let doc = Lexbor.Document("""<div>a<b>b<i>c</i></b><!--x-->d</div>""")
            div = only(Lexbor.query(doc, "div"))
            @test Lexbor.text_content(div) == "abcd"
            @test Lexbor.text(div) === nothing
            @test Lexbor.text_content(first(div)) == "a"
            cmt = only(filter(Lexbor.is_comment, collect(div)))
            @test Lexbor.text_content(cmt) == "x"
            @test Lexbor.text_content(Lexbor.Node(doc)) === nothing
        end

        let doc = Lexbor.Document("<div></div>")
            @test Lexbor.text_content(only(Lexbor.query(doc, "div"))) == ""
        end
    end

    @testset "element navigation" begin
        let doc = Lexbor.Document("""<div> <!--c--><a></a> t <b></b> </div>""")
            div = only(Lexbor.query(doc, "div"))
            a = only(Lexbor.query(doc, "a"))
            b = only(Lexbor.query(doc, "b"))

            @test Lexbor.is_text(Lexbor.first_child(div))
            @test Lexbor.first_child(a) === nothing

            @test Lexbor.first_element(div) == a
            @test Lexbor.last_element(div) == b
            @test Lexbor.next_element(a) == b
            @test Lexbor.next_element(b) === nothing
            @test Lexbor.prev_element(b) == a
            @test Lexbor.prev_element(a) === nothing
            @test Lexbor.first_element(a) === nothing
            @test Lexbor.last_element(a) === nothing
        end
    end

    @testset "closest" begin
        let doc = Lexbor.Document(
                """<section class="s"><div class="d"><span>t</span></div></section>""",
            )
            span = only(Lexbor.query(doc, "span"))
            div = only(Lexbor.query(doc, "div"))
            section = only(Lexbor.query(doc, "section"))
            @test Lexbor.closest(span, "div") == div
            @test Lexbor.closest(span, ".s") == section
            @test Lexbor.closest(span, "span") == span
            @test Lexbor.closest(span, "table") === nothing
            @test Lexbor.closest(first(span), "div") == div
            @test Lexbor.closest(span, Lexbor.Matcher("section")) == section
        end
    end

    @testset "tree mutation" begin
        let doc = Lexbor.Document("""<div id="root"></div>""")
            el = Lexbor.create_element(doc, :p)
            @test Lexbor.is_element(el)
            @test Lexbor.tag(el) === :p

            el2 = Lexbor.create_element(doc, "span")
            @test Lexbor.tag(el2) === :span

            txt = Lexbor.create_text(doc, "hello")
            @test Lexbor.is_text(txt)
            @test Lexbor.text(txt) == "hello"

            cmt = Lexbor.create_comment(doc, "note")
            @test Lexbor.is_comment(cmt)
            @test Lexbor.comment(cmt) == "note"
        end

        let doc = Lexbor.Document("""<div id="root"></div>""")
            root = only(Lexbor.query(doc, "div#root"))
            el = Lexbor.create_element(doc, :p)
            txt = Lexbor.create_text(doc, "hi")
            @test Lexbor.append_child!(el, txt) === txt
            @test Lexbor.append_child!(root, el) === el
            @test Lexbor.outer_html(root) == """<div id="root"><p>hi</p></div>"""
            @test Lexbor.tag(only(Lexbor.query(doc, "p"))) === :p
        end

        let doc = Lexbor.Document("""<ul><li id="b">b</li></ul>""")
            ul = only(Lexbor.query(doc, "ul"))
            anchor = only(Lexbor.query(doc, "li#b"))

            a = Lexbor.create_element(doc, :li)
            Lexbor.append_child!(a, Lexbor.create_text(doc, "a"))
            c = Lexbor.create_element(doc, :li)
            Lexbor.append_child!(c, Lexbor.create_text(doc, "c"))

            @test Lexbor.insert_before!(anchor, a) === a
            @test Lexbor.insert_after!(anchor, c) === c
            @test Lexbor.outer_html(ul) ==
                  """<ul><li>a</li><li id="b">b</li><li>c</li></ul>"""
            @test Lexbor.prev_sibling(anchor) == a
            @test Lexbor.next_sibling(anchor) == c
        end

        let doc = Lexbor.Document("""<div><span id="x">x</span><b>b</b></div>""")
            div = only(Lexbor.query(doc, "div"))
            span = only(Lexbor.query(doc, "span#x"))
            @test Lexbor.remove!(span) === span
            @test Lexbor.outer_html(div) == "<div><b>b</b></div>"
            @test isempty(Lexbor.query(doc, "span"))
        end

        let doc = Lexbor.Document(
                """<div id="a"><span id="s">s</span></div><div id="b"></div>""",
            )
            a = only(Lexbor.query(doc, "div#a"))
            b = only(Lexbor.query(doc, "div#b"))
            span = only(Lexbor.query(doc, "span#s"))

            Lexbor.remove!(span)
            Lexbor.append_child!(b, span)
            @test Lexbor.outer_html(a) == """<div id="a"></div>"""
            @test Lexbor.outer_html(b) == """<div id="b"><span id="s">s</span></div>"""
            @test length(Lexbor.query(doc, "span")) == 1
        end

        let doc = Lexbor.Document(
                """<div id="a"><span id="s">s</span></div><div id="b"></div>""",
            )
            a = only(Lexbor.query(doc, "div#a"))
            b = only(Lexbor.query(doc, "div#b"))
            span = only(Lexbor.query(doc, "span#s"))

            Lexbor.append_child!(b, span)
            @test Lexbor.outer_html(a) == """<div id="a"></div>"""
            @test Lexbor.outer_html(b) == """<div id="b"><span id="s">s</span></div>"""
            @test length(Lexbor.query(doc, "span")) == 1
        end

        let doc1 = Lexbor.Document("""<div id="a"></div>"""),
            doc2 = Lexbor.Document("""<div id="b"></div>""")

            a = only(Lexbor.query(doc1, "div"))
            el = Lexbor.create_element(doc2, :p)
            @test_throws ArgumentError Lexbor.append_child!(a, el)
            @test_throws ArgumentError Lexbor.insert_before!(a, el)
            @test_throws ArgumentError Lexbor.insert_after!(a, el)
        end

        let doc = Lexbor.Document("<p></p>")
            orphan = Lexbor.create_element(doc, :span)
            @test Lexbor.remove!(orphan) === orphan
        end

        let doc = Lexbor.Document("""<div><span id="s"></span></div>""")
            div = only(Lexbor.query(doc, "div"))
            span = only(Lexbor.query(doc, "span#s"))
            @test_throws ArgumentError Lexbor.append_child!(span, div)
            @test_throws ArgumentError Lexbor.append_child!(div, div)
            @test_throws ArgumentError Lexbor.append_child!(span, Lexbor.Node(doc))
            @test_throws ArgumentError Lexbor.insert_before!(span, div)
            @test_throws ArgumentError Lexbor.insert_after!(span, div)
            @test Lexbor.parent_node(span) == div
            @test Lexbor.outer_html(div) == """<div><span id="s"></span></div>"""
        end

        let doc = Lexbor.Document("""<div><a></a><b></b></div>""")
            div = only(Lexbor.query(doc, "div"))
            a = only(Lexbor.query(doc, "a"))
            b = only(Lexbor.query(doc, "b"))
            @test Lexbor.insert_before!(a, a) === a
            @test Lexbor.insert_after!(b, b) === b
            @test Lexbor.outer_html(div) == "<div><a></a><b></b></div>"
            Lexbor.insert_before!(a, b)
            @test Lexbor.outer_html(div) == "<div><b></b><a></a></div>"
        end

        let doc = Lexbor.Document("<p>t</p>")
            textnode = first(only(Lexbor.query(doc, "p")))
            el = Lexbor.create_element(doc, :b)
            @test_throws ArgumentError Lexbor.append_child!(textnode, el)
            @test_throws ArgumentError Lexbor.append_child!(el, Lexbor.Node(doc))
            @test Lexbor.outer_html(el) == "<b></b>"
        end

        let doc = Lexbor.Document("""<div><p>t</p></div>""")
            div = only(Lexbor.query(doc, "div"))
            p = only(Lexbor.query(doc, "p"))
            message(f) =
                try
                    f()
                    ""
                catch err
                    err isa ArgumentError ? err.msg : rethrow()
                end
            @test message(() -> Lexbor.append_child!(p, div)) ==
                  "cannot insert a node into itself or one of its descendants."
            @test message(() -> Lexbor.append_child!(first(p), div)) ==
                  "cannot insert into a text or comment node."
            @test message(() -> Lexbor.append_child!(Lexbor.Node(doc), Lexbor.create_element(doc, :b))) ==
                  "the document cannot hold this node here."
            @test message(() -> Lexbor.append_child!(Lexbor.Node(doc), Lexbor.create_text(doc, "x"))) ==
                  "the document cannot hold this node here."

            typed = Lexbor.Document("<!DOCTYPE html><p></p>")
            doctype = Lexbor.first_child(Lexbor.Node(typed))
            @test message(() -> Lexbor.append_child!(Lexbor.body(typed), doctype)) ==
                  "a doctype can only be a child of the document."
        end

        let doc = Lexbor.Document("<p></p>")
            orphan = Lexbor.create_element(doc, :span)
            el = Lexbor.create_element(doc, :b)
            @test_throws ArgumentError Lexbor.insert_before!(orphan, el)
            @test_throws ArgumentError Lexbor.insert_after!(orphan, el)
            @test Lexbor.next_sibling(orphan) === nothing
        end
    end

    @testset "attribute and text mutation" begin
        let doc = Lexbor.Document("""<div id="ok"><span>test</span></div>""")
            div = only(Lexbor.query(doc, "div"))

            @test Lexbor.set_attribute!(div, "data-x", "1") === div
            @test Lexbor.attribute(div, "data-x") == "1"
            @test Lexbor.attributes(div) == Dict("id" => "ok", "data-x" => "1")
            @test contains(Lexbor.outer_html(div), "data-x=\"1\"")

            Lexbor.set_attribute!(div, "id", "new")
            @test Lexbor.attribute(div, "id") == "new"
        end

        let doc = Lexbor.Document("<div></div>")
            div = only(Lexbor.query(doc, "div"))
            Lexbor.set_attribute!(div, "flag", nothing)
            @test Lexbor.attribute(div, "flag") == ""
            @test Lexbor.attributes(div)["flag"] == ""
            @test Lexbor.has_attribute(div, "flag") === true
            @test contains(Lexbor.outer_html(div), "flag=\"\"")
        end

        let doc = Lexbor.Document("""<div id="ok" data-x="1"></div>""")
            div = only(Lexbor.query(doc, "div"))
            @test Lexbor.remove_attribute!(div, "data-x") === div
            @test Lexbor.attribute(div, "data-x") === nothing
            @test Lexbor.has_attribute(div, "data-x") === false
            @test !contains(Lexbor.outer_html(div), "data-x")

            @test Lexbor.remove_attribute!(div, "nope") === div
            @test Lexbor.has_attribute(div, "nope") === false
        end

        let doc = Lexbor.Document("<p>hi</p>")
            textnode = first(only(Lexbor.query(doc, "p")))
            @test Lexbor.is_text(textnode)
            @test_throws ArgumentError Lexbor.set_attribute!(textnode, "x", "1")
            @test_throws ArgumentError Lexbor.remove_attribute!(textnode, "x")
        end

        let doc = Lexbor.Document("""<div><span>old</span></div>""")
            div = only(Lexbor.query(doc, "div"))
            @test Lexbor.set_text!(div, "a < b & c") === div
            @test isempty(Lexbor.query(doc, "span"))
            @test Lexbor.outer_html(div) == "<div>a &lt; b &amp; c</div>"
        end

        let doc = Lexbor.Document("""<div><p>old</p></div>""")
            div = only(Lexbor.query(doc, "div"))
            p = only(Lexbor.query(doc, "p"))
            Lexbor.set_text!(div, "new")
            span = Lexbor.create_element(doc, :span)
            @test Lexbor.tag(p) === :p
            @test Lexbor.parent_node(p) === nothing
            @test Lexbor.outer_html(p) == "<p>old</p>"
            Lexbor.append_child!(span, p)
            @test Lexbor.outer_html(span) == "<span><p>old</p></span>"
        end

        let doc = Lexbor.Document("<p>hello</p>")
            textnode = first(only(Lexbor.query(doc, "p")))
            @test Lexbor.set_text!(textnode, "world") === textnode
            @test Lexbor.text(textnode) == "world"
        end

        let doc = Lexbor.Document("<div><!--old--></div>")
            cmt = first(only(Lexbor.query(doc, "div")))
            @test Lexbor.is_comment(cmt)
            @test Lexbor.set_text!(cmt, "new") === cmt
            @test Lexbor.comment(cmt) == "new"
        end

        let doc = Lexbor.Document("<div></div>")
            div = only(Lexbor.query(doc, "div"))
            Lexbor.set_text!(Lexbor.set_attribute!(div, "k", "v"), "t")
            @test Lexbor.attribute(div, "k") == "v"
            @test Lexbor.outer_html(div) == """<div k="v">t</div>"""
        end
    end

    @testset "fragment parsing" begin
        let doc = Lexbor.Document("<html><body></body></html>")
            nodes = Lexbor.fragment(doc, "<li>a</li><li>b</li>")
            @test length(nodes) == 2
            @test all(Lexbor.is_element, nodes)
            @test Lexbor.tag.(nodes) == [:li, :li]
            @test all(n -> Lexbor.parent_node(n) === nothing, nodes)
        end

        let doc = Lexbor.Document("<html><body></body></html>")
            nodes = Lexbor.fragment(doc, "text<b>bold</b>")
            @test length(nodes) == 2
            @test Lexbor.is_text(nodes[1])
            @test Lexbor.text(nodes[1]) == "text"
            @test Lexbor.is_element(nodes[2])
            @test Lexbor.tag(nodes[2]) === :b
            @test all(n -> Lexbor.parent_node(n) === nothing, nodes)
        end

        let doc = Lexbor.Document("<ul></ul>")
            ul = only(Lexbor.query(doc, "ul"))
            for n in Lexbor.fragment(doc, "<li>a</li><li>b</li>")
                Lexbor.append_child!(ul, n)
            end
            @test Lexbor.outer_html(ul) == "<ul><li>a</li><li>b</li></ul>"
            @test length(Lexbor.query(doc, "li")) == 2
        end

        let doc = Lexbor.Document("<html><body></body></html>")
            nodes = Lexbor.fragment(doc, "<td>x</td>")
            @test length(nodes) == 1
            @test Lexbor.is_text(nodes[1])
            @test Lexbor.text(nodes[1]) == "x"
        end

        let doc = Lexbor.Document("<table><tr></tr></table>")
            tr = only(Lexbor.query(doc, "tr"))
            nodes = Lexbor.fragment(doc, "<td>x</td>"; context = tr)
            @test length(nodes) == 1
            @test Lexbor.is_element(nodes[1])
            @test Lexbor.tag(nodes[1]) === :td
            @test Lexbor.outer_html(nodes[1]) == "<td>x</td>"
        end

        let doc = Lexbor.Document("<html><body></body></html>")
            @test isempty(Lexbor.fragment(doc, ""))
        end

        let doc = Lexbor.Document("<p>hi</p>")
            textnode = first(only(Lexbor.query(doc, "p")))
            @test Lexbor.is_text(textnode)
            @test_throws ArgumentError Lexbor.fragment(doc, "<li>a</li>"; context = textnode)
        end

        let doc1 = Lexbor.Document("<div></div>"), doc2 = Lexbor.Document("<div></div>")
            ctx = Lexbor.body(doc2)
            @test_throws ArgumentError Lexbor.fragment(doc1, "<li>a</li>"; context = ctx)
        end
    end

    @testset "inner HTML replacement" begin
        let doc = Lexbor.Document("""<div><p>old</p></div>""")
            div = only(Lexbor.query(doc, "div"))
            p = only(Lexbor.query(doc, "p"))
            @test Lexbor.set_inner_html!(div, "<b>new</b> text") === div
            @test Lexbor.inner_html(div) == "<b>new</b> text"
            @test Lexbor.parent_node(p) === nothing
            @test Lexbor.outer_html(p) == "<p>old</p>"
        end

        let doc = Lexbor.Document("<table><tr></tr></table>")
            row = only(Lexbor.query(doc, "tr"))
            Lexbor.set_inner_html!(row, "<td>cell</td>")
            @test Lexbor.outer_html(row) == "<tr><td>cell</td></tr>"
        end

        let doc = Lexbor.Document("<p>t</p>")
            textnode = first(only(Lexbor.query(doc, "p")))
            @test_throws ArgumentError Lexbor.set_inner_html!(textnode, "<b></b>")
        end
    end

    @testset "node replacement" begin
        let doc = Lexbor.Document("""<ul><li>a</li><li id="b">b</li><li>c</li></ul>""")
            ul = only(Lexbor.query(doc, "ul"))
            b = only(Lexbor.query(doc, "li#b"))
            x = Lexbor.create_element(doc, :li)
            Lexbor.append_child!(x, Lexbor.create_text(doc, "x"))
            @test Lexbor.replace_node!(b, x) === x
            @test Lexbor.outer_html(ul) == "<ul><li>a</li><li>x</li><li>c</li></ul>"
            @test Lexbor.parent_node(b) === nothing
            @test Lexbor.outer_html(b) == """<li id="b">b</li>"""
        end

        let doc = Lexbor.Document("""<div><a></a><b></b></div>""")
            div = only(Lexbor.query(doc, "div"))
            a = only(Lexbor.query(doc, "a"))
            b = only(Lexbor.query(doc, "b"))
            @test Lexbor.replace_node!(a, a) === a
            @test Lexbor.outer_html(div) == "<div><a></a><b></b></div>"
            Lexbor.replace_node!(a, b)
            @test Lexbor.outer_html(div) == "<div><b></b></div>"
            @test_throws ArgumentError Lexbor.replace_node!(b, div)
            @test_throws ArgumentError Lexbor.replace_node!(a, b)
        end
    end

    @testset "cloning and importing" begin
        let doc = Lexbor.Document("""<div id="d" class="c"><span>t</span></div>""")
            div = only(Lexbor.query(doc, "div"))
            deep = Lexbor.clone_node(div)
            @test Lexbor.parent_node(deep) === nothing
            @test Lexbor.outer_html(deep) == Lexbor.outer_html(div)
            @test deep != div

            shallow = Lexbor.clone_node(div; deep = false)
            @test Lexbor.outer_html(shallow) == """<div id="d" class="c"></div>"""

            Lexbor.set_attribute!(deep, "id", "copy")
            @test Lexbor.attribute(div, "id") == "d"
            Lexbor.append_child!(Lexbor.body(doc), deep)
            @test length(Lexbor.query(doc, "span")) == 2
            @test_throws ArgumentError Lexbor.clone_node(Lexbor.Node(doc))
        end

        let src = Lexbor.Document("""<div id="d"><span>t</span></div>"""),
            dst = Lexbor.Document("<ul></ul>")

            div = only(Lexbor.query(src, "div"))
            imported = Lexbor.import_node(dst, div)
            @test imported.document === dst
            @test Lexbor.parent_node(imported) === nothing
            @test Lexbor.outer_html(imported) == """<div id="d"><span>t</span></div>"""
            Lexbor.append_child!(only(Lexbor.query(dst, "ul")), imported)
            @test Lexbor.outer_html(only(Lexbor.query(dst, "ul"))) ==
                  """<ul><div id="d"><span>t</span></div></ul>"""
            @test Lexbor.parent_node(div) == Lexbor.body(src)

            shallow = Lexbor.import_node(dst, div; deep = false)
            @test Lexbor.outer_html(shallow) == """<div id="d"></div>"""
            @test_throws ArgumentError Lexbor.import_node(dst, Lexbor.Node(src))
        end
    end

    @testset "title mutation" begin
        let doc = Lexbor.Document("<p>x</p>")
            @test Lexbor.set_title!(doc, "Hello & bye") === doc
            @test Lexbor.title(doc) == "Hello & bye"
            Lexbor.set_title!(doc, "Second")
            @test Lexbor.title(doc) == "Second"
            @test length(Lexbor.query(doc, "title")) == 1
        end

        let doc = Lexbor.Document("<title>old</title>")
            held = Lexbor.first_child(only(Lexbor.query(doc, "title")))
            Lexbor.set_title!(doc, "new")
            foreach(i -> Lexbor.create_comment(doc, "c$i"), 1:50)
            @test Lexbor.is_text(held)
            @test Lexbor.text(held) == "old"
            @test Lexbor.parent_node(held) === nothing
            @test Lexbor.title(doc) == "new"
        end

        let doc = Lexbor.Document("<p>x</p>")
            root = Lexbor.document_element(doc)
            Lexbor.set_inner_html!(root, "<head></head><body><p>new</p></body>")
            Lexbor.set_title!(doc, "T")
            @test Lexbor.title(doc) == "T"
            @test Lexbor.outer_html(Lexbor.head(doc)) == "<head><title>T</title></head>"
            @test Lexbor.outer_html(Lexbor.body(doc)) == "<body><p>new</p></body>"
        end

        let doc = Lexbor.Document("<p>x</p>")
            Lexbor.remove!(Lexbor.head(doc))
            @test Lexbor.set_title!(doc, "T") === doc
            @test Lexbor.title(doc) === nothing
        end
    end

    @testset "mutation during matching" begin
        let doc = Lexbor.Document("<p>a</p><p>b</p><p>c</p>")
            Lexbor.query(doc, "p") do p
                Lexbor.remove!(p)
            end
            @test isempty(Lexbor.query(doc, "p"))
        end

        let doc = Lexbor.Document("<p>a</p>")
            p = only(Lexbor.query(doc, "p"))
            seen = Lexbor.Node[]
            Lexbor.Matcher("p")(p) do n
                Lexbor.remove!(n)
                push!(seen, n)
            end
            @test seen == [p]
            @test Lexbor.parent_node(p) === nothing
        end
    end

    @testset "text replacement edge cases" begin
        let doc = Lexbor.Document("<p>x</p>")
            @test Lexbor.set_text!(Lexbor.Node(doc), "y") isa Lexbor.Node
            @test Lexbor.outer_html(doc) == "<html><head></head><body><p>x</p></body></html>"
        end

        let doc = Lexbor.Document("<p>a<b>b</b></p>")
            p = only(Lexbor.query(doc, "p"))
            Lexbor.set_text!(p, "")
            @test isempty(collect(p))
            @test Lexbor.outer_html(p) == "<p></p>"
        end
    end

    @testset "templates" begin
        let doc = Lexbor.Document("<template><p>t</p></template>")
            t = only(Lexbor.query(doc, "template"))
            @test Lexbor.inner_html(t) == "<p>t</p>"

            @test Lexbor.outer_html(Lexbor.clone_node(t)) == "<template><p>t</p></template>"
            @test Lexbor.outer_html(Lexbor.clone_node(t; deep = false)) ==
                  "<template></template>"

            other = Lexbor.Document("")
            imported = Lexbor.import_node(other, t)
            @test Lexbor.outer_html(imported) == "<template><p>t</p></template>"

            nested = Lexbor.Document(
                "<div><template><i>a</i><template><b>b</b></template></template></div>",
            )
            div = only(Lexbor.query(nested, "div"))
            @test Lexbor.outer_html(Lexbor.clone_node(div)) == Lexbor.outer_html(div)

            @test Lexbor.set_inner_html!(t, "<td>c</td>") === t
            @test Lexbor.outer_html(t) == "<template><td>c</td></template>"
            @test Lexbor.inner_html(t) == "<td>c</td>"
            @test isempty(collect(t))
        end
    end

    @testset "name validation" begin
        let doc = Lexbor.Document("<p></p>")
            p = only(Lexbor.query(doc, "p"))
            for bad in ["", "img src=x", "a/b", "a>b", "a\0b", "a\tb"]
                @test_throws ArgumentError Lexbor.create_element(doc, bad)
            end
            for bad in ["", "x onmouseover=alert(1)", "a=b", "a/b", "a>b", "a\nb"]
                @test_throws ArgumentError Lexbor.set_attribute!(p, bad, "v")
            end
            @test Lexbor.outer_html(p) == "<p></p>"

            @test Lexbor.tag(Lexbor.create_element(doc, "my-el")) === Symbol("my-el")
            Lexbor.set_attribute!(p, "@click", "f")
            Lexbor.set_attribute!(p, "data-x", "1")
            @test Lexbor.attributes(p) == Dict("@click" => "f", "data-x" => "1")
        end
    end

    @testset "replacing the document element" begin
        let doc = Lexbor.Document("<p>x</p>")
            old = Lexbor.document_element(doc)
            new = Lexbor.create_element(doc, :html)
            @test Lexbor.replace_node!(old, new) === new
            @test Lexbor.document_element(doc) == new
            @test Lexbor.parent_node(old) === nothing
        end

        let doc = Lexbor.Document("""<div><a></a><b></b></div>""")
            div = only(Lexbor.query(doc, "div"))
            a = only(Lexbor.query(doc, "a"))
            @test_throws ArgumentError Lexbor.replace_node!(a, div)
            @test Lexbor.outer_html(div) == "<div><a></a><b></b></div>"
            @test Lexbor.parent_node(div) == Lexbor.body(doc)
        end
    end
end
