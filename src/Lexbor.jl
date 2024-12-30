module Lexbor

# Imports:

import AbstractTrees

# Includes:

include("liblexbor_api.jl")

# Interface:

export Document
export Node
export query

# Implementation:

struct LexborError <: Exception
    msg::String
end

"""
    Document(html_str)
    open(Document, html_file_path)

Parse HTML into an in-memory tree representing the DOM. To parse an HTML file
use `Base.open`.
"""
mutable struct Document
    ptr::Ptr{LibLexbor.lxb_html_document_t}
    source::Union{String,Nothing}

    function Document(html_str::AbstractString, source = nothing)
        parser = LibLexbor.lxb_html_parser_create()
        if LibLexbor.lxb_html_parser_init(parser) != LibLexbor.LXB_STATUS_OK
            LibLexbor.lxb_html_parser_destroy(parser)
            throw(LexborError("error initializing HTML parser."))
        end
        ptr = LibLexbor.lxb_html_parse(parser, html_str, sizeof(html_str))
        if ptr == C_NULL
            LibLexbor.lxb_html_document_destroy(ptr)
            LibLexbor.lxb_html_parser_destroy(parser)
            throw(LexborError("error parsing HTML document"))
        end
        document = new(ptr, source)
        finalizer(document) do _
            LibLexbor.lxb_html_document_destroy(ptr)
            LibLexbor.lxb_html_parser_destroy(parser)
        end
        return document
    end
    function Document(io::IO, source = nothing)
        html_str = read(io, String)
        return Document(html_str, source)
    end
end

Base.show(io::IO, doc::Document) = print(io, "$(Document)(source = $(repr(doc.source)))")

Base.open(::Type{Document}, file::String) = Base.open(io -> Document(io, file), file, "r")

#
# Node iteration:
#

"""
    Node(document::Document)

An iterable object representing a particular node within an HTML `Document`.
"""
struct Node
    document::Document
    ptr::Ptr{LibLexbor.lxb_dom_node_t}

    Node(document::Document) = new(document, Ptr{LibLexbor.lxb_dom_node_t}(document.ptr))
    Node(document::Document, ptr::Ptr{LibLexbor.lxb_dom_node_t}) = new(document, ptr)
    Node(node::Node, ptr::Ptr{LibLexbor.lxb_dom_node_t}) = new(node.document, ptr)
end

function Base.show(io::IO, node::Node)
    if is_element(node)
        print(io, "<", tag(node), ">")
    elseif is_text(node)
        print(io, repr(text(node)))
    elseif is_comment(node)
        print(io, "<!--", comment(node), "-->")
    else
        print(io, "$(Node)($(_node_type(node)))")
    end
end

function Base.iterate(iter::Node, state = LibLexbor.lxb_dom_node_first_child_noi(iter.ptr))
    state == C_NULL && return nothing
    return Node(iter, state), LibLexbor.lxb_dom_node_next_noi(state)
end

Base.eltype(::Type{Node}) = Node
Base.IteratorSize(::Type{Node}) = Base.SizeUnknown()

AbstractTrees.children(n::Node) = Iterators.map(identity, n)
AbstractTrees.nodevalue(n::Node) = n

"""
    Tree(document)
    Tree(node)

A display type to help visualize DOM structure.
"""
struct Tree
    n::Node

    Tree(d::Document) = new(Node(d))
    Tree(n::Node) = new(n)
end

Base.show(io::IO, t::Tree) = AbstractTrees.print_tree(io, t.n)

_node_type(node::Node) = unsafe_load(node.ptr).type

is_comment(node::Node) = _node_type(node) == LibLexbor.LXB_DOM_NODE_TYPE_COMMENT
is_element(node::Node) = _node_type(node) == LibLexbor.LXB_DOM_NODE_TYPE_ELEMENT
is_text(node::Node) = _node_type(node) == LibLexbor.LXB_DOM_NODE_TYPE_TEXT

"""
    comment(node) -> String | nothing

Return the comment content of a node, or `nothing` when the node is not a valid
comment node.
"""
comment(node::Node) = is_comment(node) ? _content(node.ptr) : nothing

"""
    text(node) -> String | Nothing

Return the text content of a node, or `nothing` when the node is not a valid
text node.
"""
text(node::Node) = is_text(node) ? _content(node.ptr) : nothing

function _content(ptr::Ptr{LibLexbor.lxb_dom_node_t})
    len = Ref{Csize_t}(0)
    ptr = LibLexbor.lxb_dom_node_text_content(ptr, len)
    return ptr == C_NULL ? nothing : unsafe_string(ptr, len[])
end

"""
    tag(node) -> Symbol | Nothing

Return the element tag name, or `nothing` when it is not an element.
"""
tag(node::Node) = is_element(node) ? _element_name(node.ptr) : nothing

function _element_name(ptr::Ptr{LibLexbor.lxb_dom_node_t})
    element = Ptr{LibLexbor.lxb_dom_element_t}(ptr)
    name_len = Ref{Csize_t}(0)
    name_ptr = LibLexbor.lxb_dom_element_qualified_name(element, name_len)
    if _is_null(name_ptr)
        return nothing
    else
        return Symbol(unsafe_string(name_ptr, name_len[]))
    end
end

"""
    attributes(node::Node) -> Dict{String,Union{String,Nothing}} | Nothing

Return a `Dict` of all the attributes of a node, or `nothing` when it is not a
valid element node.
"""
attributes(node::Node) = is_element(node) ? _attributes(node.ptr) : nothing

function _attributes(node::Ptr{LibLexbor.lxb_dom_node_t})
    element = Ptr{LibLexbor.lxb_dom_element_t}(node)
    attr = LibLexbor.lxb_dom_element_first_attribute_noi(element)
    attributes = Dict{String,Union{String,Nothing}}()
    while !_is_null(attr)
        name_len = Ref{Csize_t}(0)
        name_ptr = LibLexbor.lxb_dom_attr_qualified_name(attr, name_len)
        if _is_null(name_ptr)
            @error "Attribute name is null"
            @goto next_attribute
        else
            name = unsafe_string(name_ptr, name_len[])
        end

        value_len = Ref{Csize_t}(0)
        value_ptr = LibLexbor.lxb_dom_attr_value_noi(attr, value_len)
        value = _is_null(value_ptr) ? nothing : unsafe_string(value_ptr, value_len[])

        attributes[name] = value

        @label next_attribute
        attr = LibLexbor.lxb_dom_element_next_attribute_noi(attr)
    end
    return attributes
end

_is_null(node::Ptr{T}) where {T} = node === Ptr{T}()

#
# Query nodes:
#

"""
    query(document | node, selector) -> Node[]
    query(f, document | node, selector) -> nothing

Query the `document` or `node` for the given CSS `selector`. When `f` is
provided then call `f` on each match that is found and return `nothing` from
`query`. When no `f` is provided then just return a `Vector{Node}` containing
all matches.
"""
function query end

# Node iterator:

struct QueryContext{F}
    document::Document
    f::F
end

@noinline function __each_query_callback(node, spec, ref)
    ctx = ref[]
    ctx.f(Node(ctx.document, node))
    return LibLexbor.LXB_STATUS_OK
end

# To allow revising the callback function, we define a wrapper function so that
# the function point remains stable between revisions.
@noinline _each_query_callback(node, spec, ctx) = __each_query_callback(node, spec, ctx)

@noinline _c_each_query_callback() = @cfunction(
    _each_query_callback,
    LibLexbor.lexbor_status_t,
    (
        Ptr{LibLexbor.lxb_dom_node_t},
        Ptr{LibLexbor.lxb_css_selector_specificity_t},
        Ref{QueryContext},
    )
)

struct CSSSelectorError <: Exception
    msg::String
    css::String
end

function query(f, node::Node, selector::String)
    parser = LibLexbor.lxb_css_parser_create()
    status = LibLexbor.lxb_css_parser_init(parser, C_NULL)
    if status != LibLexbor.LXB_STATUS_OK
        LibLexbor.lxb_css_parser_destroy(parser, true)
        throw(LexborError("could not create css parser."))
    end

    selectors = LibLexbor.lxb_selectors_create()
    status = LibLexbor.lxb_selectors_init(selectors)
    if status != LibLexbor.LXB_STATUS_OK
        LibLexbor.lxb_selectors_destroy(selectors, true)
        LibLexbor.lxb_css_parser_destroy(parser, true)
        throw(LexborError("could not create selectors."))
    end

    list = LibLexbor.lxb_css_selectors_parse(parser, selector, sizeof(selector))
    if unsafe_load(parser).status != LibLexbor.LXB_STATUS_OK
        LibLexbor.lxb_selectors_destroy(selectors, true)
        LibLexbor.lxb_css_parser_destroy(parser, true)
        LibLexbor.lxb_css_selector_list_destroy_memory(list)
        throw(CSSSelectorError("could not parse css selectors.", selector))
    end

    try
        status = LibLexbor.lxb_selectors_find(
            selectors,
            node.ptr,
            list,
            _c_each_query_callback(),
            Ref(QueryContext(node.document, f)),
        )
        if status != LibLexbor.LXB_STATUS_OK
            throw(LexborError("failed to find selectors."))
        end
    finally
        LibLexbor.lxb_selectors_destroy(selectors, true)
        LibLexbor.lxb_css_parser_destroy(parser, true)
        LibLexbor.lxb_css_selector_list_destroy_memory(list)
    end

    return nothing
end
query(f, doc::Document, selector::String) = query(f, Node(doc), selector)

# Node collector:

struct CollectNodes
    nodes::Vector{Node}
end

(cn::CollectNodes)(node::Node) = push!(cn.nodes, node)

function query(node::Node, selector::String)
    nodes = Node[]
    query(CollectNodes(nodes), node, selector)
    return nodes
end
query(doc::Document, selector::String) = query(Node(doc), selector)

end
