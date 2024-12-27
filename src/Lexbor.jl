module Lexbor

# Imports:

import AbstractTrees

# Includes:

include("liblexbor_api.jl")

# Interface:

export Document
export Node

# Implementation:

struct Node
    tag::String
    attributes::Vector{Pair{String,Union{String,Nothing}}}
    children::Vector{Union{String,Node}}
    source::Union{Nothing,Tuple{Int,Int}}
end

AbstractTrees.children(node::Node) = node.children
function AbstractTrees.nodevalue(node::Node)
    return node.tag, node.source
end

struct Document
    root::Node
    source::Union{Nothing,String}

    function Document(str::String, source = nothing)
        root = _parse_html(str)
        return new(root, source)
    end
    Document(io::IO, source = nothing) = Document(read(io, String), source)
end

Base.show(io::IO, doc::Document) = print(io, "$(Document)(source = $(repr(doc.source)))")

Base.open(::Type{Document}, file::String) = Base.open(io -> Document(io, file), file, "r")

# Token source information:

_destroy_document(doc) = LibLexbor.lxb_html_document_destroy(doc)

@noinline function __token_callback(tkz, token, ctx)
    _begin = unsafe_load(token)._begin
    _begin == C_NULL && return token

    type = unsafe_load(token).type
    is_close = type == LibLexbor.LXB_HTML_TOKEN_TYPE_CLOSE

    tags = LibLexbor.lxb_html_tokenizer_tags_noi(tkz)
    tag_id = unsafe_load(token).tag_id
    tag_ptr = LibLexbor.lxb_tag_name_by_id_noi(tags, tag_id, C_NULL)
    tag_ptr == C_NULL && return token
    tag = unsafe_string(tag_ptr)

    # TODO: potentially others that need handling.
    offset = tag == "#text" ? 1 : tag == "!doctype" ? -1 : 0

    # Find the line and column of the token.
    token_offset = Int(offset + UInt(_begin) - ctx.html_start_ptr)
    tk_line_range = searchsorted(ctx.line_starts, (token_offset, 0); by = first)
    tk_line_start = first(tk_line_range)
    tk_line_end = last(tk_line_range)
    tk_line_index = clamp(min(tk_line_start, tk_line_end), 1, length(ctx.line_starts))
    line_start_offset, token_line = ctx.line_starts[tk_line_index]
    token_column = token_offset - line_start_offset

    push!(ctx.token_positions, (tag, is_close, token_line, token_column))

    return token
end
# To allow revising the callback function, we define a wrapper function so that
# the function point remains stable between revisions.
@noinline _token_callback(tkz, token, ctx) = __token_callback(tkz, token, ctx)

@noinline _c_token_callback() = @cfunction(
    _token_callback,
    Ptr{LibLexbor.lxb_html_token_t},
    (
        Ptr{LibLexbor.lxb_html_tokenizer_t},
        Ptr{LibLexbor.lxb_html_token_t},
        Ref{
            @NamedTuple{
                html_start_ptr::UInt,
                line_starts::Vector{Tuple{Int,Int}},
                token_positions::Vector{Tuple{String,Bool,Int,Int}},
            }
        },
    )
)

# Helper function to check the status of the tokenizer return value.
function _check_status(tkz, status, message)
    if status != LibLexbor.LXB_STATUS_OK
        LibLexbor.lxb_html_tokenizer_destroy(tkz)
        throw(ErrorException(message))
    end
end

function _line_mapping(str::String)
    line_starts = Tuple{Int,Int}[]
    offset = 0
    for (nth_line, line) in enumerate(eachline(IOBuffer(str); keep = true))
        push!(line_starts, (offset, nth_line))
        offset += ncodeunits(line)
    end
    push!(line_starts, (offset + 1, length(line_starts) + 1))
    return line_starts
end

function _token_positions(str::String)
    line_starts = _line_mapping(str)

    tkz = LibLexbor.lxb_html_tokenizer_create()
    status = LibLexbor.lxb_html_tokenizer_init(tkz)
    _check_status(tkz, status, "Error initializing HTML tokenizer")

    c_callback = _c_token_callback()

    html_start_ptr = UInt(pointer(str))
    token_positions = Tuple{String,Bool,Int,Int}[]
    LibLexbor.lxb_html_tokenizer_callback_token_done_set_noi(
        tkz,
        c_callback,
        Ref((; html_start_ptr, line_starts, token_positions)),
    )

    status = LibLexbor.lxb_html_tokenizer_begin(tkz)
    _check_status(tkz, status, "Error initializing HTML tokenizer")

    status = LibLexbor.lxb_html_tokenizer_chunk(tkz, str, sizeof(str))
    _check_status(tkz, status, "Error tokenizing HTML")

    status = LibLexbor.lxb_html_tokenizer_end(tkz)
    _check_status(tkz, status, "Error finalizing HTML tokenizer")

    LibLexbor.lxb_html_tokenizer_destroy(tkz)

    return token_positions
end

# HTML Parsing:

function _with_lexbor_parser(func::Function)
    parser = LibLexbor.lxb_html_parser_create()
    status = LibLexbor.lxb_html_parser_init(parser)
    if status != LibLexbor.LXB_STATUS_OK
        LibLexbor.lxb_html_parser_destroy(parser)
        throw(ErrorException("Error initializing HTML parser"))
    end
    try
        func(parser)
    finally
        LibLexbor.lxb_html_parser_destroy(parser)
    end
end

function _with_lexbor_document(func::Function, html_str::String)
    _with_lexbor_parser() do parser
        doc_ptr = LibLexbor.lxb_html_parse(parser, html_str, sizeof(html_str))
        if doc_ptr == C_NULL
            throw(ErrorException("Error parsing HTML"))
        end
        try
            func(doc_ptr)
        finally
            LibLexbor.lxb_html_document_destroy(doc_ptr)
        end
    end
end

function _parse_html(html_str::String)
    return _with_lexbor_document(html_str) do doc_ptr
        source_info = _token_positions(html_str)
        node_ptr = Ptr{LibLexbor.lxb_dom_node_t}(doc_ptr)
        return Node(node_ptr, source_info)
    end
end

function Node(node_ptr::Ptr{LibLexbor.lxb_dom_node_t}, source_info)
    type = unsafe_load(node_ptr).type
    if type === LibLexbor.LXB_DOM_NODE_TYPE_TEXT
        len = Ref{Csize_t}(0)
        ptr = LibLexbor.lxb_dom_node_text_content(node_ptr, len)
        return ptr == C_NULL ? "" : unsafe_string(ptr, len[])
    elseif type === LibLexbor.LXB_DOM_NODE_TYPE_ELEMENT
        attributes = _attributes(node_ptr)
        tag = _element_name(node_ptr)
        source = findfirst(x -> x[1] == tag && !x[2], source_info)
        source_data = nothing
        if !isnothing(source)
            _, _, line_info, col_info = source_info[source]
            source_data = (line_info, col_info)
            deleteat!(source_info, 1:source)
        end
        children = Node.(NodeChildren(node_ptr), Ref(source_info))
        return Node(tag, attributes, children, source_data)
    elseif type === LibLexbor.LXB_DOM_NODE_TYPE_DOCUMENT
        return Node(
            "#document",
            [],
            Node.(NodeChildren(node_ptr), Ref(source_info)),
            (1, 1),
        )
    elseif type === LibLexbor.LXB_DOM_NODE_TYPE_DOCUMENT_TYPE
        source = findfirst(x -> x[1] == "!doctype" && !x[2], source_info)
        source_data = nothing
        if !isnothing(source)
            _, _, line_info, col_info = source_info[source]
            source_data = (line_info, col_info)
            deleteat!(source_info, 1:source)
        end
        return Node("!doctype", [], [], source_data)
    elseif type === LibLexbor.LXB_DOM_NODE_TYPE_COMMENT
        len = Ref{Csize_t}(0)
        ptr = LibLexbor.lxb_dom_node_text_content(node_ptr, len)
        content = ptr == C_NULL ? "" : unsafe_string(ptr, len[])

        source = findfirst(x -> x[1] == "!--" && !x[2], source_info)
        source_data = nothing
        if !isnothing(source)
            _, _, line_info, col_info = source_info[source]
            source_data = (line_info, col_info)
            deleteat!(source_info, 1:source)
        end

        return Node("!--", [], [content], source_data)
    else
        error("Unhandled node type: $type")
    end
end

struct NodeChildren
    node_ptr::Ptr{LibLexbor.lxb_dom_node_t}
end

function Base.iterate(
    iter::NodeChildren,
    state = LibLexbor.lxb_dom_node_first_child_noi(iter.node_ptr),
)
    state == C_NULL && return nothing

    # When an empty text node with no other siblings then include it, otherwise
    # skip it. TODO: confirm this is suitable behavior.
    if unsafe_load(state).type === LibLexbor.LXB_DOM_NODE_TYPE_TEXT
        next_node = LibLexbor.lxb_dom_node_next_noi(state)
        prev_node = LibLexbor.lxb_dom_node_prev_noi(state)
        if (next_node == C_NULL && prev_node == C_NULL)
            # Covers the case where it is a pre or code block that is empty.
            return state, LibLexbor.lxb_dom_node_next_noi(state)
        else
            len = Ref{Csize_t}(0)
            ptr = LibLexbor.lxb_dom_node_text_content(state, len)
            text = ptr == C_NULL ? "" : unsafe_string(ptr, len[])
            stripped_text = strip(text)
            if isempty(stripped_text)
                return iterate(iter, LibLexbor.lxb_dom_node_next_noi(state))
            else
                return state, LibLexbor.lxb_dom_node_next_noi(state)
            end
        end
    end

    return state, LibLexbor.lxb_dom_node_next_noi(state)
end

Base.eltype(::Type{NodeChildren}) = Ptr{LibLexbor.lxb_dom_node_t}
Base.IteratorSize(::Type{NodeChildren}) = Base.SizeUnknown()

_type(node) = unsafe_load(node).type
_is_null(node::Ptr{T}) where {T} = node === Ptr{T}()

function _element_name(node::Ptr{LibLexbor.lxb_dom_node_t})
    element = Ptr{LibLexbor.lxb_dom_element_t}(node)
    name_len = Ref{Csize_t}(0)
    name_ptr = LibLexbor.lxb_dom_element_qualified_name(element, name_len)
    if _is_null(name_ptr)
        return nothing
    else
        return unsafe_string(name_ptr, name_len[])
    end
end

function _attributes(node::Ptr{LibLexbor.lxb_dom_node_t})
    element = Ptr{LibLexbor.lxb_dom_element_t}(node)
    attr = LibLexbor.lxb_dom_element_first_attribute_noi(element)
    attributes = Pair{String,Union{String,Nothing}}[]
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

        push!(attributes, name => value)

        @label next_attribute
        attr = LibLexbor.lxb_dom_element_next_attribute_noi(attr)
    end
    return attributes
end

function find_all_nodes(tag::String, doc::Document)
    nodes = Node[]
    for each in AbstractTrees.PostOrderDFS(doc.root)
        if _is_tag(each, tag)
            push!(nodes, each)
        end
    end
    return nodes
end

_is_tag(n::Node, t) = n.tag == t
_is_tag(other, t) = false

iselement(node::Node) = true
iselement(text::AbstractString) = false

nodename(node::Node) = node.tag

nodes(node::Node) = node.children

istext(node::Node) = false
istext(text::AbstractString) = true

end
