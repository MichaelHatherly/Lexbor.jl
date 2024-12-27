module LibLexbor

using lexbor_jll
export lexbor_jll

using CEnum

uint32_t(value) = UInt32(value)

const __darwin_intptr_t = Clong

const intptr_t = __darwin_intptr_t

const lxb_char_t = Cuchar

struct lexbor_mem_chunk
    data::Ptr{UInt8}
    length::Csize_t
    size::Csize_t
    next::Ptr{Cvoid} # next::Ptr{lexbor_mem_chunk_t}
    prev::Ptr{Cvoid} # prev::Ptr{lexbor_mem_chunk_t}
end

function Base.getproperty(x::lexbor_mem_chunk, f::Symbol)
    f === :next && return Ptr{lexbor_mem_chunk_t}(getfield(x, f))
    f === :prev && return Ptr{lexbor_mem_chunk_t}(getfield(x, f))
    return getfield(x, f)
end

const lexbor_mem_chunk_t = lexbor_mem_chunk

struct lexbor_mem
    chunk::Ptr{lexbor_mem_chunk_t}
    chunk_first::Ptr{lexbor_mem_chunk_t}
    chunk_min_size::Csize_t
    chunk_length::Csize_t
end

const lexbor_mem_t = lexbor_mem

struct lexbor_array_t
    list::Ptr{Ptr{Cvoid}}
    size::Csize_t
    length::Csize_t
end

struct lexbor_dobject_t
    mem::Ptr{lexbor_mem_t}
    cache::Ptr{lexbor_array_t}
    allocated::Csize_t
    struct_size::Csize_t
end

struct lexbor_bst_entry
    value::Ptr{Cvoid}
    right::Ptr{Cvoid} # right::Ptr{lexbor_bst_entry_t}
    left::Ptr{Cvoid} # left::Ptr{lexbor_bst_entry_t}
    next::Ptr{Cvoid} # next::Ptr{lexbor_bst_entry_t}
    parent::Ptr{Cvoid} # parent::Ptr{lexbor_bst_entry_t}
    size::Csize_t
end

function Base.getproperty(x::lexbor_bst_entry, f::Symbol)
    f === :right && return Ptr{lexbor_bst_entry_t}(getfield(x, f))
    f === :left && return Ptr{lexbor_bst_entry_t}(getfield(x, f))
    f === :next && return Ptr{lexbor_bst_entry_t}(getfield(x, f))
    f === :parent && return Ptr{lexbor_bst_entry_t}(getfield(x, f))
    return getfield(x, f)
end

const lexbor_bst_entry_t = lexbor_bst_entry

struct lexbor_bst
    dobject::Ptr{lexbor_dobject_t}
    root::Ptr{lexbor_bst_entry_t}
    tree_length::Csize_t
end

const lexbor_bst_t = lexbor_bst

struct lexbor_mraw_t
    mem::Ptr{lexbor_mem_t}
    cache::Ptr{lexbor_bst_t}
    ref_count::Csize_t
end

struct lxb_dom_event_target
    events::Ptr{Cvoid}
end

const lxb_dom_event_target_t = lxb_dom_event_target

@cenum lxb_dom_node_type_t::UInt32 begin
    LXB_DOM_NODE_TYPE_UNDEF = 0
    LXB_DOM_NODE_TYPE_ELEMENT = 1
    LXB_DOM_NODE_TYPE_ATTRIBUTE = 2
    LXB_DOM_NODE_TYPE_TEXT = 3
    LXB_DOM_NODE_TYPE_CDATA_SECTION = 4
    LXB_DOM_NODE_TYPE_ENTITY_REFERENCE = 5
    LXB_DOM_NODE_TYPE_ENTITY = 6
    LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION = 7
    LXB_DOM_NODE_TYPE_COMMENT = 8
    LXB_DOM_NODE_TYPE_DOCUMENT = 9
    LXB_DOM_NODE_TYPE_DOCUMENT_TYPE = 10
    LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT = 11
    LXB_DOM_NODE_TYPE_NOTATION = 12
    LXB_DOM_NODE_TYPE_LAST_ENTRY = 13
end

struct lxb_dom_node
    event_target::lxb_dom_event_target_t
    local_name::Csize_t
    prefix::Csize_t
    ns::Csize_t
    owner_document::Ptr{Cvoid} # owner_document::Ptr{lxb_dom_document_t}
    next::Ptr{Cvoid} # next::Ptr{lxb_dom_node_t}
    prev::Ptr{Cvoid} # prev::Ptr{lxb_dom_node_t}
    parent::Ptr{Cvoid} # parent::Ptr{lxb_dom_node_t}
    first_child::Ptr{Cvoid} # first_child::Ptr{lxb_dom_node_t}
    last_child::Ptr{Cvoid} # last_child::Ptr{lxb_dom_node_t}
    user::Ptr{Cvoid}
    type::lxb_dom_node_type_t
end

function Base.getproperty(x::lxb_dom_node, f::Symbol)
    f === :owner_document && return Ptr{lxb_dom_document_t}(getfield(x, f))
    f === :next && return Ptr{lxb_dom_node_t}(getfield(x, f))
    f === :prev && return Ptr{lxb_dom_node_t}(getfield(x, f))
    f === :parent && return Ptr{lxb_dom_node_t}(getfield(x, f))
    f === :first_child && return Ptr{lxb_dom_node_t}(getfield(x, f))
    f === :last_child && return Ptr{lxb_dom_node_t}(getfield(x, f))
    return getfield(x, f)
end

const lxb_dom_node_t = lxb_dom_node

struct lexbor_str_t
    data::Ptr{lxb_char_t}
    length::Csize_t
end

struct lxb_dom_character_data
    node::lxb_dom_node_t
    data::lexbor_str_t
end

const lxb_dom_character_data_t = lxb_dom_character_data

struct lxb_dom_text
    char_data::lxb_dom_character_data_t
end

const lxb_dom_text_t = lxb_dom_text

struct lxb_dom_cdata_section
    text::lxb_dom_text_t
end

const lxb_dom_cdata_section_t = lxb_dom_cdata_section

struct lxb_dom_comment
    char_data::lxb_dom_character_data_t
end

const lxb_dom_comment_t = lxb_dom_comment

@cenum lxb_dom_document_cmode_t::UInt32 begin
    LXB_DOM_DOCUMENT_CMODE_NO_QUIRKS = 0
    LXB_DOM_DOCUMENT_CMODE_QUIRKS = 1
    LXB_DOM_DOCUMENT_CMODE_LIMITED_QUIRKS = 2
end

@cenum lxb_dom_document_dtype_t::UInt32 begin
    LXB_DOM_DOCUMENT_DTYPE_UNDEF = 0
    LXB_DOM_DOCUMENT_DTYPE_HTML = 1
    LXB_DOM_DOCUMENT_DTYPE_XML = 2
end

const lxb_dom_attr_id_t = Csize_t

struct lxb_dom_document_type
    node::lxb_dom_node_t
    name::lxb_dom_attr_id_t
    public_id::lexbor_str_t
    system_id::lexbor_str_t
end

const lxb_dom_document_type_t = lxb_dom_document_type

struct lxb_dom_attr
    node::lxb_dom_node_t
    upper_name::lxb_dom_attr_id_t
    qualified_name::lxb_dom_attr_id_t
    value::Ptr{lexbor_str_t}
    owner::Ptr{Cvoid} # owner::Ptr{lxb_dom_element_t}
    next::Ptr{Cvoid} # next::Ptr{lxb_dom_attr_t}
    prev::Ptr{Cvoid} # prev::Ptr{lxb_dom_attr_t}
end

function Base.getproperty(x::lxb_dom_attr, f::Symbol)
    f === :owner && return Ptr{lxb_dom_element_t}(getfield(x, f))
    f === :next && return Ptr{lxb_dom_attr_t}(getfield(x, f))
    f === :prev && return Ptr{lxb_dom_attr_t}(getfield(x, f))
    return getfield(x, f)
end

const lxb_dom_attr_t = lxb_dom_attr

@cenum lxb_dom_element_custom_state_t::UInt32 begin
    LXB_DOM_ELEMENT_CUSTOM_STATE_UNDEFINED = 0
    LXB_DOM_ELEMENT_CUSTOM_STATE_FAILED = 1
    LXB_DOM_ELEMENT_CUSTOM_STATE_UNCUSTOMIZED = 2
    LXB_DOM_ELEMENT_CUSTOM_STATE_CUSTOM = 3
end

struct lxb_dom_element
    node::lxb_dom_node_t
    upper_name::lxb_dom_attr_id_t
    qualified_name::lxb_dom_attr_id_t
    is_value::Ptr{lexbor_str_t}
    first_attr::Ptr{lxb_dom_attr_t}
    last_attr::Ptr{lxb_dom_attr_t}
    attr_id::Ptr{lxb_dom_attr_t}
    attr_class::Ptr{lxb_dom_attr_t}
    custom_state::lxb_dom_element_custom_state_t
end

const lxb_dom_element_t = lxb_dom_element

# typedef lxb_dom_interface_t * ( * lxb_dom_interface_create_f ) ( lxb_dom_document_t * document , lxb_tag_id_t tag_id , lxb_ns_id_t ns )
const lxb_dom_interface_create_f = Ptr{Cvoid}

# typedef lxb_dom_interface_t * ( * lxb_dom_interface_clone_f ) ( lxb_dom_document_t * document , const lxb_dom_interface_t * intrfc )
const lxb_dom_interface_clone_f = Ptr{Cvoid}

# typedef lxb_dom_interface_t * ( * lxb_dom_interface_destroy_f ) ( lxb_dom_interface_t * intrfc )
const lxb_dom_interface_destroy_f = Ptr{Cvoid}

# typedef lxb_status_t ( * lxb_dom_event_insert_f ) ( lxb_dom_node_t * node )
const lxb_dom_event_insert_f = Ptr{Cvoid}

# typedef lxb_status_t ( * lxb_dom_event_remove_f ) ( lxb_dom_node_t * node )
const lxb_dom_event_remove_f = Ptr{Cvoid}

# typedef lxb_status_t ( * lxb_dom_event_destroy_f ) ( lxb_dom_node_t * node )
const lxb_dom_event_destroy_f = Ptr{Cvoid}

# typedef lxb_status_t ( * lxb_dom_event_set_value_f ) ( lxb_dom_node_t * node , const lxb_char_t * value , size_t length )
const lxb_dom_event_set_value_f = Ptr{Cvoid}

struct __JL_Ctag_276
    data::NTuple{24,UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_276}, f::Symbol)
    f === :long_str && return Ptr{Ptr{lxb_char_t}}(x + 0)
    f === :short_str && return Ptr{NTuple{17,lxb_char_t}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_276, f::Symbol)
    r = Ref{__JL_Ctag_276}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_276}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_276}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct lexbor_hash_entry
    data::NTuple{40,UInt8}
end

function Base.getproperty(x::Ptr{lexbor_hash_entry}, f::Symbol)
    f === :u && return Ptr{__JL_Ctag_276}(x + 0)
    f === :length && return Ptr{Csize_t}(x + 24)
    f === :next && return Ptr{Ptr{lexbor_hash_entry_t}}(x + 32)
    return getfield(x, f)
end

function Base.getproperty(x::lexbor_hash_entry, f::Symbol)
    r = Ref{lexbor_hash_entry}(x)
    ptr = Base.unsafe_convert(Ptr{lexbor_hash_entry}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{lexbor_hash_entry}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const lexbor_hash_entry_t = lexbor_hash_entry

struct lexbor_hash
    entries::Ptr{lexbor_dobject_t}
    mraw::Ptr{lexbor_mraw_t}
    table::Ptr{Ptr{lexbor_hash_entry_t}}
    table_size::Csize_t
    struct_size::Csize_t
end

const lexbor_hash_t = lexbor_hash

struct lxb_dom_document
    node::lxb_dom_node_t
    compat_mode::lxb_dom_document_cmode_t
    type::lxb_dom_document_dtype_t
    doctype::Ptr{lxb_dom_document_type_t}
    element::Ptr{lxb_dom_element_t}
    create_interface::lxb_dom_interface_create_f
    clone_interface::lxb_dom_interface_clone_f
    destroy_interface::lxb_dom_interface_destroy_f
    ev_insert::lxb_dom_event_insert_f
    ev_remove::lxb_dom_event_remove_f
    ev_destroy::lxb_dom_event_destroy_f
    ev_set_value::lxb_dom_event_set_value_f
    mraw::Ptr{lexbor_mraw_t}
    text::Ptr{lexbor_mraw_t}
    tags::Ptr{lexbor_hash_t}
    attrs::Ptr{lexbor_hash_t}
    prefix::Ptr{lexbor_hash_t}
    ns::Ptr{lexbor_hash_t}
    parser::Ptr{Cvoid}
    user::Ptr{Cvoid}
    tags_inherited::Bool
    ns_inherited::Bool
    scripting::Bool
end

const lxb_dom_document_t = lxb_dom_document

struct lxb_dom_document_fragment
    node::lxb_dom_node_t
    host::Ptr{lxb_dom_element_t}
end

const lxb_dom_document_fragment_t = lxb_dom_document_fragment

struct lxb_dom_processing_instruction
    char_data::lxb_dom_character_data_t
    target::lexbor_str_t
end

const lxb_dom_processing_instruction_t = lxb_dom_processing_instruction

@cenum lxb_dom_shadow_root_mode_t::UInt32 begin
    LXB_DOM_SHADOW_ROOT_MODE_OPEN = 0
    LXB_DOM_SHADOW_ROOT_MODE_CLOSED = 1
end

struct lxb_dom_shadow_root
    document_fragment::lxb_dom_document_fragment_t
    mode::lxb_dom_shadow_root_mode_t
    host::Ptr{lxb_dom_element_t}
end

const lxb_dom_shadow_root_t = lxb_dom_shadow_root

struct lexbor_avl_node
    type::Csize_t
    height::Cshort
    value::Ptr{Cvoid}
    left::Ptr{Cvoid} # left::Ptr{lexbor_avl_node_t}
    right::Ptr{Cvoid} # right::Ptr{lexbor_avl_node_t}
    parent::Ptr{Cvoid} # parent::Ptr{lexbor_avl_node_t}
end

function Base.getproperty(x::lexbor_avl_node, f::Symbol)
    f === :left && return Ptr{lexbor_avl_node_t}(getfield(x, f))
    f === :right && return Ptr{lexbor_avl_node_t}(getfield(x, f))
    f === :parent && return Ptr{lexbor_avl_node_t}(getfield(x, f))
    return getfield(x, f)
end

const lexbor_avl_node_t = lexbor_avl_node

@cenum lxb_css_rule_type_t::UInt32 begin
    LXB_CSS_RULE_UNDEF = 0
    LXB_CSS_RULE_STYLESHEET = 1
    LXB_CSS_RULE_LIST = 2
    LXB_CSS_RULE_AT_RULE = 3
    LXB_CSS_RULE_STYLE = 4
    LXB_CSS_RULE_BAD_STYLE = 5
    LXB_CSS_RULE_DECLARATION_LIST = 6
    LXB_CSS_RULE_DECLARATION = 7
end

struct lxb_css_memory
    objs::Ptr{lexbor_dobject_t}
    mraw::Ptr{lexbor_mraw_t}
    tree::Ptr{lexbor_mraw_t}
    ref_count::Csize_t
end

const lxb_css_memory_t = lxb_css_memory

struct lxb_css_rule
    type::lxb_css_rule_type_t
    next::Ptr{Cvoid} # next::Ptr{lxb_css_rule_t}
    prev::Ptr{Cvoid} # prev::Ptr{lxb_css_rule_t}
    parent::Ptr{Cvoid} # parent::Ptr{lxb_css_rule_t}
    _begin::Ptr{lxb_char_t}
    _end::Ptr{lxb_char_t}
    memory::Ptr{lxb_css_memory_t}
    ref_count::Csize_t
end

function Base.getproperty(x::lxb_css_rule, f::Symbol)
    f === :next && return Ptr{lxb_css_rule_t}(getfield(x, f))
    f === :prev && return Ptr{lxb_css_rule_t}(getfield(x, f))
    f === :parent && return Ptr{lxb_css_rule_t}(getfield(x, f))
    return getfield(x, f)
end

const lxb_css_rule_t = lxb_css_rule

struct lxb_css_rule_declaration_list
    rule::lxb_css_rule_t
    first::Ptr{lxb_css_rule_t}
    last::Ptr{lxb_css_rule_t}
    count::Csize_t
end

const lxb_css_rule_declaration_list_t = lxb_css_rule_declaration_list

struct lxb_html_element
    element::lxb_dom_element_t
    style::Ptr{lexbor_avl_node_t}
    list::Ptr{lxb_css_rule_declaration_list_t}
end

const lxb_html_element_t = lxb_html_element

struct lxb_html_head_element
    element::lxb_html_element_t
end

const lxb_html_head_element_t = lxb_html_head_element

struct lxb_html_body_element
    element::lxb_html_element_t
end

const lxb_html_body_element_t = lxb_html_body_element

@cenum lxb_css_selector_type_t::UInt32 begin
    LXB_CSS_SELECTOR_TYPE__UNDEF = 0
    LXB_CSS_SELECTOR_TYPE_ANY = 1
    LXB_CSS_SELECTOR_TYPE_ELEMENT = 2
    LXB_CSS_SELECTOR_TYPE_ID = 3
    LXB_CSS_SELECTOR_TYPE_CLASS = 4
    LXB_CSS_SELECTOR_TYPE_ATTRIBUTE = 5
    LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS = 6
    LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS_FUNCTION = 7
    LXB_CSS_SELECTOR_TYPE_PSEUDO_ELEMENT = 8
    LXB_CSS_SELECTOR_TYPE_PSEUDO_ELEMENT_FUNCTION = 9
    LXB_CSS_SELECTOR_TYPE__LAST_ENTRY = 10
end

@cenum lxb_css_selector_combinator_t::UInt32 begin
    LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT = 0
    LXB_CSS_SELECTOR_COMBINATOR_CLOSE = 1
    LXB_CSS_SELECTOR_COMBINATOR_CHILD = 2
    LXB_CSS_SELECTOR_COMBINATOR_SIBLING = 3
    LXB_CSS_SELECTOR_COMBINATOR_FOLLOWING = 4
    LXB_CSS_SELECTOR_COMBINATOR_CELL = 5
    LXB_CSS_SELECTOR_COMBINATOR__LAST_ENTRY = 6
end

struct lxb_css_selector_u
    data::NTuple{24,UInt8}
end

function Base.getproperty(x::Ptr{lxb_css_selector_u}, f::Symbol)
    f === :attribute && return Ptr{lxb_css_selector_attribute_t}(x + 0)
    f === :pseudo && return Ptr{lxb_css_selector_pseudo_t}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::lxb_css_selector_u, f::Symbol)
    r = Ref{lxb_css_selector_u}(x)
    ptr = Base.unsafe_convert(Ptr{lxb_css_selector_u}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{lxb_css_selector_u}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct lxb_css_selector
    data::NTuple{88,UInt8}
end

function Base.getproperty(x::Ptr{lxb_css_selector}, f::Symbol)
    f === :type && return Ptr{lxb_css_selector_type_t}(x + 0)
    f === :combinator && return Ptr{lxb_css_selector_combinator_t}(x + 4)
    f === :name && return Ptr{lexbor_str_t}(x + 8)
    f === :ns && return Ptr{lexbor_str_t}(x + 24)
    f === :u && return Ptr{lxb_css_selector_u}(x + 40)
    f === :next && return Ptr{Ptr{lxb_css_selector_t}}(x + 64)
    f === :prev && return Ptr{Ptr{lxb_css_selector_t}}(x + 72)
    f === :list && return Ptr{Ptr{lxb_css_selector_list_t}}(x + 80)
    return getfield(x, f)
end

function Base.getproperty(x::lxb_css_selector, f::Symbol)
    r = Ref{lxb_css_selector}(x)
    ptr = Base.unsafe_convert(Ptr{lxb_css_selector}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{lxb_css_selector}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const lxb_css_selector_t = lxb_css_selector

const lxb_css_selector_specificity_t = UInt32

struct lxb_css_selector_list
    first::Ptr{lxb_css_selector_t}
    last::Ptr{lxb_css_selector_t}
    parent::Ptr{lxb_css_selector_t}
    next::Ptr{Cvoid} # next::Ptr{lxb_css_selector_list_t}
    prev::Ptr{Cvoid} # prev::Ptr{lxb_css_selector_list_t}
    memory::Ptr{lxb_css_memory_t}
    specificity::lxb_css_selector_specificity_t
end

function Base.getproperty(x::lxb_css_selector_list, f::Symbol)
    f === :next && return Ptr{lxb_css_selector_list_t}(getfield(x, f))
    f === :prev && return Ptr{lxb_css_selector_list_t}(getfield(x, f))
    return getfield(x, f)
end

const lxb_css_selector_list_t = lxb_css_selector_list

struct lxb_css_selectors
    list::Ptr{lxb_css_selector_list_t}
    list_last::Ptr{lxb_css_selector_list_t}
    parent::Ptr{lxb_css_selector_t}
    combinator::lxb_css_selector_combinator_t
    comb_default::lxb_css_selector_combinator_t
    error::Csize_t
    status::Bool
    err_in_function::Bool
    failed::Bool
end

const lxb_css_selectors_t = lxb_css_selectors

# typedef bool ( * lxb_css_parser_state_f ) ( lxb_css_parser_t * parser , const lxb_css_syntax_token_t * token , void * ctx )
const lxb_css_parser_state_f = Ptr{Cvoid}

struct lxb_css_syntax_token_u
    data::NTuple{80,UInt8}
end

function Base.getproperty(x::Ptr{lxb_css_syntax_token_u}, f::Symbol)
    f === :base && return Ptr{lxb_css_syntax_token_base_t}(x + 0)
    f === :comment && return Ptr{lxb_css_syntax_token_comment_t}(x + 0)
    f === :number && return Ptr{lxb_css_syntax_token_number_t}(x + 0)
    f === :dimension && return Ptr{lxb_css_syntax_token_dimension_t}(x + 0)
    f === :percentage && return Ptr{lxb_css_syntax_token_percentage_t}(x + 0)
    f === :hash && return Ptr{lxb_css_syntax_token_hash_t}(x + 0)
    f === :string && return Ptr{lxb_css_syntax_token_string_t}(x + 0)
    f === :bad_string && return Ptr{lxb_css_syntax_token_bad_string_t}(x + 0)
    f === :delim && return Ptr{lxb_css_syntax_token_delim_t}(x + 0)
    f === :lparenthesis && return Ptr{lxb_css_syntax_token_l_parenthesis_t}(x + 0)
    f === :rparenthesis && return Ptr{lxb_css_syntax_token_r_parenthesis_t}(x + 0)
    f === :cdc && return Ptr{lxb_css_syntax_token_cdc_t}(x + 0)
    f === :_function && return Ptr{lxb_css_syntax_token_function_t}(x + 0)
    f === :ident && return Ptr{lxb_css_syntax_token_ident_t}(x + 0)
    f === :url && return Ptr{lxb_css_syntax_token_url_t}(x + 0)
    f === :bad_url && return Ptr{lxb_css_syntax_token_bad_url_t}(x + 0)
    f === :at_keyword && return Ptr{lxb_css_syntax_token_at_keyword_t}(x + 0)
    f === :whitespace && return Ptr{lxb_css_syntax_token_whitespace_t}(x + 0)
    f === :terminated && return Ptr{lxb_css_syntax_token_terminated_t}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::lxb_css_syntax_token_u, f::Symbol)
    r = Ref{lxb_css_syntax_token_u}(x)
    ptr = Base.unsafe_convert(Ptr{lxb_css_syntax_token_u}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{lxb_css_syntax_token_u}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum lxb_css_syntax_token_type_t::UInt32 begin
    LXB_CSS_SYNTAX_TOKEN_UNDEF = 0
    LXB_CSS_SYNTAX_TOKEN_IDENT = 1
    LXB_CSS_SYNTAX_TOKEN_FUNCTION = 2
    LXB_CSS_SYNTAX_TOKEN_AT_KEYWORD = 3
    LXB_CSS_SYNTAX_TOKEN_HASH = 4
    LXB_CSS_SYNTAX_TOKEN_STRING = 5
    LXB_CSS_SYNTAX_TOKEN_BAD_STRING = 6
    LXB_CSS_SYNTAX_TOKEN_URL = 7
    LXB_CSS_SYNTAX_TOKEN_BAD_URL = 8
    LXB_CSS_SYNTAX_TOKEN_COMMENT = 9
    LXB_CSS_SYNTAX_TOKEN_WHITESPACE = 10
    LXB_CSS_SYNTAX_TOKEN_DIMENSION = 11
    LXB_CSS_SYNTAX_TOKEN_DELIM = 12
    LXB_CSS_SYNTAX_TOKEN_NUMBER = 13
    LXB_CSS_SYNTAX_TOKEN_PERCENTAGE = 14
    LXB_CSS_SYNTAX_TOKEN_CDO = 15
    LXB_CSS_SYNTAX_TOKEN_CDC = 16
    LXB_CSS_SYNTAX_TOKEN_COLON = 17
    LXB_CSS_SYNTAX_TOKEN_SEMICOLON = 18
    LXB_CSS_SYNTAX_TOKEN_COMMA = 19
    LXB_CSS_SYNTAX_TOKEN_LS_BRACKET = 20
    LXB_CSS_SYNTAX_TOKEN_RS_BRACKET = 21
    LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS = 22
    LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS = 23
    LXB_CSS_SYNTAX_TOKEN_LC_BRACKET = 24
    LXB_CSS_SYNTAX_TOKEN_RC_BRACKET = 25
    LXB_CSS_SYNTAX_TOKEN__EOF = 26
    LXB_CSS_SYNTAX_TOKEN__TERMINATED = 27
    LXB_CSS_SYNTAX_TOKEN__END = 27
    LXB_CSS_SYNTAX_TOKEN__LAST_ENTRY = 28
end

struct lxb_css_syntax_token
    data::NTuple{104,UInt8}
end

function Base.getproperty(x::Ptr{lxb_css_syntax_token}, f::Symbol)
    f === :types && return Ptr{lxb_css_syntax_token_u}(x + 0)
    f === :type && return Ptr{lxb_css_syntax_token_type_t}(x + 80)
    f === :offset && return Ptr{Csize_t}(x + 88)
    f === :cloned && return Ptr{Bool}(x + 96)
    return getfield(x, f)
end

function Base.getproperty(x::lxb_css_syntax_token, f::Symbol)
    r = Ref{lxb_css_syntax_token}(x)
    ptr = Base.unsafe_convert(Ptr{lxb_css_syntax_token}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{lxb_css_syntax_token}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const lxb_css_syntax_token_t = lxb_css_syntax_token

struct lxb_css_syntax_tokenizer_cache_t
    list::Ptr{Ptr{lxb_css_syntax_token_t}}
    size::Csize_t
    length::Csize_t
end

struct lexbor_array_obj_t
    list::Ptr{UInt8}
    size::Csize_t
    length::Csize_t
    struct_size::Csize_t
end

# typedef lxb_status_t ( * lxb_css_syntax_tokenizer_chunk_f ) ( lxb_css_syntax_tokenizer_t * tkz , const lxb_char_t * * data , const lxb_char_t * * end , void * ctx )
const lxb_css_syntax_tokenizer_chunk_f = Ptr{Cvoid}

# typedef const lxb_char_t * ( * lxb_css_syntax_token_data_cb_f ) ( const lxb_char_t * begin , const lxb_char_t * end , lexbor_str_t * str , lexbor_mraw_t * mraw , lxb_css_syntax_token_data_t * td )
const lxb_css_syntax_token_data_cb_f = Ptr{Cvoid}

const lxb_status_t = Cuint

struct lxb_css_syntax_token_data
    cb::lxb_css_syntax_token_data_cb_f
    status::lxb_status_t
    count::Cint
    num::UInt32
    is_last::Bool
end

const lxb_css_syntax_token_data_t = lxb_css_syntax_token_data

struct lxb_css_syntax_tokenizer
    cache::Ptr{lxb_css_syntax_tokenizer_cache_t}
    tokens::Ptr{lexbor_dobject_t}
    parse_errors::Ptr{lexbor_array_obj_t}
    in_begin::Ptr{lxb_char_t}
    in_end::Ptr{lxb_char_t}
    _begin::Ptr{lxb_char_t}
    offset::Csize_t
    cache_pos::Csize_t
    prepared::Csize_t
    mraw::Ptr{lexbor_mraw_t}
    chunk_cb::lxb_css_syntax_tokenizer_chunk_f
    chunk_ctx::Ptr{Cvoid}
    start::Ptr{lxb_char_t}
    pos::Ptr{lxb_char_t}
    _end::Ptr{lxb_char_t}
    buffer::NTuple{128,lxb_char_t}
    token_data::lxb_css_syntax_token_data_t
    opt::Cuint
    status::lxb_status_t
    eof::Bool
    with_comment::Bool
end

const lxb_css_syntax_tokenizer_t = lxb_css_syntax_tokenizer

# typedef const lxb_css_syntax_token_t * ( * lxb_css_syntax_state_f ) ( lxb_css_parser_t * parser , const lxb_css_syntax_token_t * token , lxb_css_syntax_rule_t * rule )
const lxb_css_syntax_state_f = Ptr{Cvoid}

struct __JL_Ctag_270
    data::NTuple{8,UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_270}, f::Symbol)
    f === :cb && return Ptr{Ptr{lxb_css_syntax_cb_base_t}}(x + 0)
    f === :list_rules && return Ptr{Ptr{lxb_css_syntax_cb_list_rules_t}}(x + 0)
    f === :at_rule && return Ptr{Ptr{lxb_css_syntax_cb_at_rule_t}}(x + 0)
    f === :qualified_rule && return Ptr{Ptr{lxb_css_syntax_cb_qualified_rule_t}}(x + 0)
    f === :declarations && return Ptr{Ptr{lxb_css_syntax_cb_declarations_t}}(x + 0)
    f === :components && return Ptr{Ptr{lxb_css_syntax_cb_components_t}}(x + 0)
    f === :func && return Ptr{Ptr{lxb_css_syntax_cb_function_t}}(x + 0)
    f === :block && return Ptr{Ptr{lxb_css_syntax_cb_block_t}}(x + 0)
    f === :pipe && return Ptr{Ptr{lxb_css_syntax_cb_pipe_t}}(x + 0)
    f === :user && return Ptr{Ptr{Cvoid}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_270, f::Symbol)
    r = Ref{__JL_Ctag_270}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_270}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_270}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct __JL_Ctag_271
    data::NTuple{56,UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_271}, f::Symbol)
    f === :list_rules && return Ptr{lxb_css_syntax_list_rules_offset_t}(x + 0)
    f === :at_rule && return Ptr{lxb_css_syntax_at_rule_offset_t}(x + 0)
    f === :qualified && return Ptr{lxb_css_syntax_qualified_offset_t}(x + 0)
    f === :declarations && return Ptr{lxb_css_syntax_declarations_offset_t}(x + 0)
    f === :user && return Ptr{Ptr{Cvoid}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_271, f::Symbol)
    r = Ref{__JL_Ctag_271}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_271}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_271}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct lxb_css_syntax_rule
    data::NTuple{136,UInt8}
end

function Base.getproperty(x::Ptr{lxb_css_syntax_rule}, f::Symbol)
    f === :phase && return Ptr{lxb_css_syntax_state_f}(x + 0)
    f === :state && return Ptr{lxb_css_parser_state_f}(x + 8)
    f === :state_back && return Ptr{lxb_css_parser_state_f}(x + 16)
    f === :back && return Ptr{lxb_css_syntax_state_f}(x + 24)
    f === :cbx && return Ptr{__JL_Ctag_270}(x + 32)
    f === :context && return Ptr{Ptr{Cvoid}}(x + 40)
    f === :offset && return Ptr{Csize_t}(x + 48)
    f === :deep && return Ptr{Csize_t}(x + 56)
    f === :block_end && return Ptr{lxb_css_syntax_token_type_t}(x + 64)
    f === :skip_ending && return Ptr{Bool}(x + 68)
    f === :skip_consume && return Ptr{Bool}(x + 69)
    f === :important && return Ptr{Bool}(x + 70)
    f === :failed && return Ptr{Bool}(x + 71)
    f === :top_level && return Ptr{Bool}(x + 72)
    f === :u && return Ptr{__JL_Ctag_271}(x + 80)
    return getfield(x, f)
end

function Base.getproperty(x::lxb_css_syntax_rule, f::Symbol)
    r = Ref{lxb_css_syntax_rule}(x)
    ptr = Base.unsafe_convert(Ptr{lxb_css_syntax_rule}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{lxb_css_syntax_rule}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const lxb_css_syntax_rule_t = lxb_css_syntax_rule

struct lxb_css_parser_state
    state::lxb_css_parser_state_f
    context::Ptr{Cvoid}
    root::Bool
end

const lxb_css_parser_state_t = lxb_css_parser_state

struct lxb_css_log_t
    messages::lexbor_array_obj_t
    mraw::Ptr{lexbor_mraw_t}
    self_mraw::Bool
end

@cenum lxb_css_parser_stage_t::UInt32 begin
    LXB_CSS_PARSER_CLEAN = 0
    LXB_CSS_PARSER_RUN = 1
    LXB_CSS_PARSER_STOP = 2
    LXB_CSS_PARSER_END = 3
end

struct lxb_css_parser
    block::lxb_css_parser_state_f
    context::Ptr{Cvoid}
    tkz::Ptr{lxb_css_syntax_tokenizer_t}
    selectors::Ptr{lxb_css_selectors_t}
    old_selectors::Ptr{lxb_css_selectors_t}
    memory::Ptr{lxb_css_memory_t}
    old_memory::Ptr{lxb_css_memory_t}
    rules_begin::Ptr{lxb_css_syntax_rule_t}
    rules_end::Ptr{lxb_css_syntax_rule_t}
    rules::Ptr{lxb_css_syntax_rule_t}
    states_begin::Ptr{lxb_css_parser_state_t}
    states_end::Ptr{lxb_css_parser_state_t}
    states::Ptr{lxb_css_parser_state_t}
    types_begin::Ptr{lxb_css_syntax_token_type_t}
    types_end::Ptr{lxb_css_syntax_token_type_t}
    types_pos::Ptr{lxb_css_syntax_token_type_t}
    chunk_cb::lxb_css_syntax_tokenizer_chunk_f
    chunk_ctx::Ptr{Cvoid}
    pos::Ptr{lxb_char_t}
    offset::Csize_t
    str::lexbor_str_t
    str_size::Csize_t
    log::Ptr{lxb_css_log_t}
    stage::lxb_css_parser_stage_t
    loop::Bool
    fake_null::Bool
    my_tkz::Bool
    receive_endings::Bool
    status::lxb_status_t
end

const lxb_css_parser_t = lxb_css_parser

struct lxb_selectors_t
    objs::Ptr{lexbor_dobject_t}
    chld::Ptr{lexbor_dobject_t}
    status::lxb_status_t
end

struct lexbor_avl
    nodes::Ptr{lexbor_dobject_t}
    last_right::Ptr{lexbor_avl_node_t}
end

const lexbor_avl_t = lexbor_avl

struct lxb_html_document_css_t
    memory::Ptr{lxb_css_memory_t}
    css_selectors::Ptr{lxb_css_selectors_t}
    parser::Ptr{lxb_css_parser_t}
    selectors::Ptr{lxb_selectors_t}
    styles::Ptr{lexbor_avl_t}
    stylesheets::Ptr{lexbor_array_t}
    weak::Ptr{lexbor_dobject_t}
    customs::Ptr{lexbor_hash_t}
    customs_id::Csize_t
end

# typedef lxb_status_t ( * lxb_html_document_done_cb_f ) ( lxb_html_document_t * document )
const lxb_html_document_done_cb_f = Ptr{Cvoid}

@cenum lxb_html_document_ready_state_t::UInt32 begin
    LXB_HTML_DOCUMENT_READY_STATE_UNDEF = 0
    LXB_HTML_DOCUMENT_READY_STATE_LOADING = 1
    LXB_HTML_DOCUMENT_READY_STATE_INTERACTIVE = 2
    LXB_HTML_DOCUMENT_READY_STATE_COMPLETE = 3
end

const lxb_html_document_opt_t = Cuint

struct lxb_html_document
    dom_document::lxb_dom_document_t
    iframe_srcdoc::Ptr{Cvoid}
    head::Ptr{lxb_html_head_element_t}
    body::Ptr{lxb_html_body_element_t}
    css::lxb_html_document_css_t
    css_init::Bool
    done::lxb_html_document_done_cb_f
    ready_state::lxb_html_document_ready_state_t
    opt::lxb_html_document_opt_t
end

const lxb_html_document_t = lxb_html_document

struct lxb_html_anchor_element
    element::lxb_html_element_t
end

const lxb_html_anchor_element_t = lxb_html_anchor_element

struct lxb_html_area_element
    element::lxb_html_element_t
end

const lxb_html_area_element_t = lxb_html_area_element

struct lxb_html_media_element
    element::lxb_html_element_t
end

const lxb_html_media_element_t = lxb_html_media_element

struct lxb_html_audio_element
    media_element::lxb_html_media_element_t
end

const lxb_html_audio_element_t = lxb_html_audio_element

struct lxb_html_br_element
    element::lxb_html_element_t
end

const lxb_html_br_element_t = lxb_html_br_element

struct lxb_html_base_element
    element::lxb_html_element_t
end

const lxb_html_base_element_t = lxb_html_base_element

struct lxb_html_button_element
    element::lxb_html_element_t
end

const lxb_html_button_element_t = lxb_html_button_element

struct lxb_html_canvas_element
    element::lxb_html_element_t
end

const lxb_html_canvas_element_t = lxb_html_canvas_element

struct lxb_html_d_list_element
    element::lxb_html_element_t
end

const lxb_html_d_list_element_t = lxb_html_d_list_element

struct lxb_html_data_element
    element::lxb_html_element_t
end

const lxb_html_data_element_t = lxb_html_data_element

struct lxb_html_data_list_element
    element::lxb_html_element_t
end

const lxb_html_data_list_element_t = lxb_html_data_list_element

struct lxb_html_details_element
    element::lxb_html_element_t
end

const lxb_html_details_element_t = lxb_html_details_element

struct lxb_html_dialog_element
    element::lxb_html_element_t
end

const lxb_html_dialog_element_t = lxb_html_dialog_element

struct lxb_html_directory_element
    element::lxb_html_element_t
end

const lxb_html_directory_element_t = lxb_html_directory_element

struct lxb_html_div_element
    element::lxb_html_element_t
end

const lxb_html_div_element_t = lxb_html_div_element

struct lxb_html_embed_element
    element::lxb_html_element_t
end

const lxb_html_embed_element_t = lxb_html_embed_element

struct lxb_html_field_set_element
    element::lxb_html_element_t
end

const lxb_html_field_set_element_t = lxb_html_field_set_element

struct lxb_html_font_element
    element::lxb_html_element_t
end

const lxb_html_font_element_t = lxb_html_font_element

struct lxb_html_form_element
    element::lxb_html_element_t
end

const lxb_html_form_element_t = lxb_html_form_element

struct lxb_html_frame_element
    element::lxb_html_element_t
end

const lxb_html_frame_element_t = lxb_html_frame_element

struct lxb_html_frame_set_element
    element::lxb_html_element_t
end

const lxb_html_frame_set_element_t = lxb_html_frame_set_element

struct lxb_html_hr_element
    element::lxb_html_element_t
end

const lxb_html_hr_element_t = lxb_html_hr_element

struct lxb_html_heading_element
    element::lxb_html_element_t
end

const lxb_html_heading_element_t = lxb_html_heading_element

struct lxb_html_html_element
    element::lxb_html_element_t
end

const lxb_html_html_element_t = lxb_html_html_element

struct lxb_html_iframe_element
    element::lxb_html_element_t
end

const lxb_html_iframe_element_t = lxb_html_iframe_element

struct lxb_html_image_element
    element::lxb_html_element_t
end

const lxb_html_image_element_t = lxb_html_image_element

struct lxb_html_input_element
    element::lxb_html_element_t
end

const lxb_html_input_element_t = lxb_html_input_element

struct lxb_html_li_element
    element::lxb_html_element_t
end

const lxb_html_li_element_t = lxb_html_li_element

struct lxb_html_label_element
    element::lxb_html_element_t
end

const lxb_html_label_element_t = lxb_html_label_element

struct lxb_html_legend_element
    element::lxb_html_element_t
end

const lxb_html_legend_element_t = lxb_html_legend_element

struct lxb_html_link_element
    element::lxb_html_element_t
end

const lxb_html_link_element_t = lxb_html_link_element

struct lxb_html_map_element
    element::lxb_html_element_t
end

const lxb_html_map_element_t = lxb_html_map_element

struct lxb_html_marquee_element
    element::lxb_html_element_t
end

const lxb_html_marquee_element_t = lxb_html_marquee_element

struct lxb_html_menu_element
    element::lxb_html_element_t
end

const lxb_html_menu_element_t = lxb_html_menu_element

struct lxb_html_meta_element
    element::lxb_html_element_t
end

const lxb_html_meta_element_t = lxb_html_meta_element

struct lxb_html_meter_element
    element::lxb_html_element_t
end

const lxb_html_meter_element_t = lxb_html_meter_element

struct lxb_html_mod_element
    element::lxb_html_element_t
end

const lxb_html_mod_element_t = lxb_html_mod_element

struct lxb_html_o_list_element
    element::lxb_html_element_t
end

const lxb_html_o_list_element_t = lxb_html_o_list_element

struct lxb_html_object_element
    element::lxb_html_element_t
end

const lxb_html_object_element_t = lxb_html_object_element

struct lxb_html_opt_group_element
    element::lxb_html_element_t
end

const lxb_html_opt_group_element_t = lxb_html_opt_group_element

struct lxb_html_option_element
    element::lxb_html_element_t
end

const lxb_html_option_element_t = lxb_html_option_element

struct lxb_html_output_element
    element::lxb_html_element_t
end

const lxb_html_output_element_t = lxb_html_output_element

struct lxb_html_paragraph_element
    element::lxb_html_element_t
end

const lxb_html_paragraph_element_t = lxb_html_paragraph_element

struct lxb_html_param_element
    element::lxb_html_element_t
end

const lxb_html_param_element_t = lxb_html_param_element

struct lxb_html_picture_element
    element::lxb_html_element_t
end

const lxb_html_picture_element_t = lxb_html_picture_element

struct lxb_html_pre_element
    element::lxb_html_element_t
end

const lxb_html_pre_element_t = lxb_html_pre_element

struct lxb_html_progress_element
    element::lxb_html_element_t
end

const lxb_html_progress_element_t = lxb_html_progress_element

struct lxb_html_quote_element
    element::lxb_html_element_t
end

const lxb_html_quote_element_t = lxb_html_quote_element

struct lxb_html_script_element
    element::lxb_html_element_t
end

const lxb_html_script_element_t = lxb_html_script_element

struct lxb_html_select_element
    element::lxb_html_element_t
end

const lxb_html_select_element_t = lxb_html_select_element

struct lxb_html_slot_element
    element::lxb_html_element_t
end

const lxb_html_slot_element_t = lxb_html_slot_element

struct lxb_html_source_element
    element::lxb_html_element_t
end

const lxb_html_source_element_t = lxb_html_source_element

struct lxb_html_span_element
    element::lxb_html_element_t
end

const lxb_html_span_element_t = lxb_html_span_element

struct lxb_css_stylesheet
    root::Ptr{lxb_css_rule_t}
    memory::Ptr{lxb_css_memory_t}
    element::Ptr{Cvoid}
end

const lxb_css_stylesheet_t = lxb_css_stylesheet

struct lxb_html_style_element
    element::lxb_html_element_t
    stylesheet::Ptr{lxb_css_stylesheet_t}
end

const lxb_html_style_element_t = lxb_html_style_element

struct lxb_html_table_caption_element
    element::lxb_html_element_t
end

const lxb_html_table_caption_element_t = lxb_html_table_caption_element

struct lxb_html_table_cell_element
    element::lxb_html_element_t
end

const lxb_html_table_cell_element_t = lxb_html_table_cell_element

struct lxb_html_table_col_element
    element::lxb_html_element_t
end

const lxb_html_table_col_element_t = lxb_html_table_col_element

struct lxb_html_table_element
    element::lxb_html_element_t
end

const lxb_html_table_element_t = lxb_html_table_element

struct lxb_html_table_row_element
    element::lxb_html_element_t
end

const lxb_html_table_row_element_t = lxb_html_table_row_element

struct lxb_html_table_section_element
    element::lxb_html_element_t
end

const lxb_html_table_section_element_t = lxb_html_table_section_element

struct lxb_html_template_element
    element::lxb_html_element_t
    content::Ptr{lxb_dom_document_fragment_t}
end

const lxb_html_template_element_t = lxb_html_template_element

struct lxb_html_text_area_element
    element::lxb_html_element_t
end

const lxb_html_text_area_element_t = lxb_html_text_area_element

struct lxb_html_time_element
    element::lxb_html_element_t
end

const lxb_html_time_element_t = lxb_html_time_element

struct lxb_html_title_element
    element::lxb_html_element_t
    strict_text::Ptr{lexbor_str_t}
end

const lxb_html_title_element_t = lxb_html_title_element

struct lxb_html_track_element
    element::lxb_html_element_t
end

const lxb_html_track_element_t = lxb_html_track_element

struct lxb_html_u_list_element
    element::lxb_html_element_t
end

const lxb_html_u_list_element_t = lxb_html_u_list_element

struct lxb_html_unknown_element
    element::lxb_html_element_t
end

const lxb_html_unknown_element_t = lxb_html_unknown_element

struct lxb_html_video_element
    media_element::lxb_html_media_element_t
end

const lxb_html_video_element_t = lxb_html_video_element

struct lxb_html_window
    event_target::lxb_dom_event_target_t
end

const lxb_html_window_t = lxb_html_window

struct lxb_css_syntax_token_base
    _begin::Ptr{lxb_char_t}
    length::Csize_t
    user_id::Csize_t
end

const lxb_css_syntax_token_base_t = lxb_css_syntax_token_base

struct lxb_css_syntax_token_string
    base::lxb_css_syntax_token_base_t
    data::Ptr{lxb_char_t}
    length::Csize_t
end

const lxb_css_syntax_token_string_t = lxb_css_syntax_token_string

const lxb_css_syntax_token_ident_t = lxb_css_syntax_token_string_t

const lxb_css_syntax_token_function_t = lxb_css_syntax_token_string_t

const lxb_css_syntax_token_at_keyword_t = lxb_css_syntax_token_string_t

const lxb_css_syntax_token_hash_t = lxb_css_syntax_token_string_t

const lxb_css_syntax_token_bad_string_t = lxb_css_syntax_token_string_t

const lxb_css_syntax_token_url_t = lxb_css_syntax_token_string_t

const lxb_css_syntax_token_bad_url_t = lxb_css_syntax_token_string_t

struct lxb_css_syntax_token_delim
    base::lxb_css_syntax_token_base_t
    character::lxb_char_t
end

const lxb_css_syntax_token_delim_t = lxb_css_syntax_token_delim

struct lxb_css_syntax_token_number
    base::lxb_css_syntax_token_base_t
    num::Cdouble
    is_float::Bool
    have_sign::Bool
end

const lxb_css_syntax_token_number_t = lxb_css_syntax_token_number

const lxb_css_syntax_token_percentage_t = lxb_css_syntax_token_number_t

struct lxb_css_syntax_token_dimension
    num::lxb_css_syntax_token_number_t
    str::lxb_css_syntax_token_string_t
end

const lxb_css_syntax_token_dimension_t = lxb_css_syntax_token_dimension

const lxb_css_syntax_token_whitespace_t = lxb_css_syntax_token_string_t

const lxb_css_syntax_token_cdo_t = lxb_css_syntax_token_base_t

const lxb_css_syntax_token_cdc_t = lxb_css_syntax_token_base_t

const lxb_css_syntax_token_colon_t = lxb_css_syntax_token_base_t

const lxb_css_syntax_token_semicolon_t = lxb_css_syntax_token_base_t

const lxb_css_syntax_token_comma_t = lxb_css_syntax_token_base_t

const lxb_css_syntax_token_ls_bracket_t = lxb_css_syntax_token_base_t

const lxb_css_syntax_token_rs_bracket_t = lxb_css_syntax_token_base_t

const lxb_css_syntax_token_l_parenthesis_t = lxb_css_syntax_token_base_t

const lxb_css_syntax_token_r_parenthesis_t = lxb_css_syntax_token_base_t

const lxb_css_syntax_token_lc_bracket_t = lxb_css_syntax_token_base_t

const lxb_css_syntax_token_rc_bracket_t = lxb_css_syntax_token_base_t

const lxb_css_syntax_token_comment_t = lxb_css_syntax_token_string_t

struct lxb_css_rule_list
    rule::lxb_css_rule_t
    first::Ptr{lxb_css_rule_t}
    last::Ptr{lxb_css_rule_t}
end

const lxb_css_rule_list_t = lxb_css_rule_list

struct __JL_Ctag_269
    data::NTuple{8,UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_269}, f::Symbol)
    f === :undef && return Ptr{Ptr{lxb_css_at_rule__undef_t}}(x + 0)
    f === :custom && return Ptr{Ptr{lxb_css_at_rule__custom_t}}(x + 0)
    f === :media && return Ptr{Ptr{lxb_css_at_rule_media_t}}(x + 0)
    f === :ns && return Ptr{Ptr{lxb_css_at_rule_namespace_t}}(x + 0)
    f === :user && return Ptr{Ptr{Cvoid}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_269, f::Symbol)
    r = Ref{__JL_Ctag_269}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_269}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_269}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct lxb_css_rule_at
    data::NTuple{80,UInt8}
end

function Base.getproperty(x::Ptr{lxb_css_rule_at}, f::Symbol)
    f === :rule && return Ptr{lxb_css_rule_t}(x + 0)
    f === :type && return Ptr{Csize_t}(x + 64)
    f === :u && return Ptr{__JL_Ctag_269}(x + 72)
    return getfield(x, f)
end

function Base.getproperty(x::lxb_css_rule_at, f::Symbol)
    r = Ref{lxb_css_rule_at}(x)
    ptr = Base.unsafe_convert(Ptr{lxb_css_rule_at}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{lxb_css_rule_at}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const lxb_css_rule_at_t = lxb_css_rule_at

struct lxb_css_rule_style
    rule::lxb_css_rule_t
    selector::Ptr{lxb_css_selector_list_t}
    declarations::Ptr{lxb_css_rule_declaration_list_t}
end

const lxb_css_rule_style_t = lxb_css_rule_style

struct lxb_css_rule_bad_style
    rule::lxb_css_rule_t
    selectors::lexbor_str_t
    declarations::Ptr{lxb_css_rule_declaration_list_t}
end

const lxb_css_rule_bad_style_t = lxb_css_rule_bad_style

struct __JL_Ctag_278
    data::NTuple{8,UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_278}, f::Symbol)
    f === :undef && return Ptr{Ptr{lxb_css_property__undef_t}}(x + 0)
    f === :custom && return Ptr{Ptr{lxb_css_property__custom_t}}(x + 0)
    f === :display && return Ptr{Ptr{lxb_css_property_display_t}}(x + 0)
    f === :order && return Ptr{Ptr{lxb_css_property_order_t}}(x + 0)
    f === :visibility && return Ptr{Ptr{lxb_css_property_visibility_t}}(x + 0)
    f === :width && return Ptr{Ptr{lxb_css_property_width_t}}(x + 0)
    f === :height && return Ptr{Ptr{lxb_css_property_height_t}}(x + 0)
    f === :box_sizing && return Ptr{Ptr{lxb_css_property_box_sizing_t}}(x + 0)
    f === :margin && return Ptr{Ptr{lxb_css_property_margin_t}}(x + 0)
    f === :margin_top && return Ptr{Ptr{lxb_css_property_margin_top_t}}(x + 0)
    f === :margin_right && return Ptr{Ptr{lxb_css_property_margin_right_t}}(x + 0)
    f === :margin_bottom && return Ptr{Ptr{lxb_css_property_margin_bottom_t}}(x + 0)
    f === :margin_left && return Ptr{Ptr{lxb_css_property_margin_left_t}}(x + 0)
    f === :padding && return Ptr{Ptr{lxb_css_property_padding_t}}(x + 0)
    f === :padding_top && return Ptr{Ptr{lxb_css_property_padding_top_t}}(x + 0)
    f === :padding_right && return Ptr{Ptr{lxb_css_property_padding_right_t}}(x + 0)
    f === :padding_bottom && return Ptr{Ptr{lxb_css_property_padding_bottom_t}}(x + 0)
    f === :padding_left && return Ptr{Ptr{lxb_css_property_padding_left_t}}(x + 0)
    f === :border && return Ptr{Ptr{lxb_css_property_border_t}}(x + 0)
    f === :border_top && return Ptr{Ptr{lxb_css_property_border_top_t}}(x + 0)
    f === :border_right && return Ptr{Ptr{lxb_css_property_border_right_t}}(x + 0)
    f === :border_bottom && return Ptr{Ptr{lxb_css_property_border_bottom_t}}(x + 0)
    f === :border_left && return Ptr{Ptr{lxb_css_property_border_left_t}}(x + 0)
    f === :border_top_color && return Ptr{Ptr{lxb_css_property_border_top_color_t}}(x + 0)
    f === :border_right_color &&
        return Ptr{Ptr{lxb_css_property_border_right_color_t}}(x + 0)
    f === :border_bottom_color &&
        return Ptr{Ptr{lxb_css_property_border_bottom_color_t}}(x + 0)
    f === :border_left_color && return Ptr{Ptr{lxb_css_property_border_left_color_t}}(x + 0)
    f === :background_color && return Ptr{Ptr{lxb_css_property_background_color_t}}(x + 0)
    f === :color && return Ptr{Ptr{lxb_css_property_color_t}}(x + 0)
    f === :opacity && return Ptr{Ptr{lxb_css_property_opacity_t}}(x + 0)
    f === :position && return Ptr{Ptr{lxb_css_property_position_t}}(x + 0)
    f === :top && return Ptr{Ptr{lxb_css_property_top_t}}(x + 0)
    f === :right && return Ptr{Ptr{lxb_css_property_right_t}}(x + 0)
    f === :bottom && return Ptr{Ptr{lxb_css_property_bottom_t}}(x + 0)
    f === :left && return Ptr{Ptr{lxb_css_property_left_t}}(x + 0)
    f === :inset_block_start && return Ptr{Ptr{lxb_css_property_inset_block_start_t}}(x + 0)
    f === :inset_inline_start &&
        return Ptr{Ptr{lxb_css_property_inset_inline_start_t}}(x + 0)
    f === :inset_block_end && return Ptr{Ptr{lxb_css_property_inset_block_end_t}}(x + 0)
    f === :inset_inline_end && return Ptr{Ptr{lxb_css_property_inset_inline_end_t}}(x + 0)
    f === :text_transform && return Ptr{Ptr{lxb_css_property_text_transform_t}}(x + 0)
    f === :text_align && return Ptr{Ptr{lxb_css_property_text_align_t}}(x + 0)
    f === :text_align_all && return Ptr{Ptr{lxb_css_property_text_align_all_t}}(x + 0)
    f === :text_align_last && return Ptr{Ptr{lxb_css_property_text_align_last_t}}(x + 0)
    f === :text_justify && return Ptr{Ptr{lxb_css_property_text_justify_t}}(x + 0)
    f === :text_indent && return Ptr{Ptr{lxb_css_property_text_indent_t}}(x + 0)
    f === :white_space && return Ptr{Ptr{lxb_css_property_white_space_t}}(x + 0)
    f === :tab_size && return Ptr{Ptr{lxb_css_property_tab_size_t}}(x + 0)
    f === :word_break && return Ptr{Ptr{lxb_css_property_word_break_t}}(x + 0)
    f === :line_break && return Ptr{Ptr{lxb_css_property_line_break_t}}(x + 0)
    f === :hyphens && return Ptr{Ptr{lxb_css_property_hyphens_t}}(x + 0)
    f === :overflow_wrap && return Ptr{Ptr{lxb_css_property_overflow_wrap_t}}(x + 0)
    f === :word_wrap && return Ptr{Ptr{lxb_css_property_word_wrap_t}}(x + 0)
    f === :word_spacing && return Ptr{Ptr{lxb_css_property_word_spacing_t}}(x + 0)
    f === :letter_spacing && return Ptr{Ptr{lxb_css_property_letter_spacing_t}}(x + 0)
    f === :hanging_punctuation &&
        return Ptr{Ptr{lxb_css_property_hanging_punctuation_t}}(x + 0)
    f === :font_family && return Ptr{Ptr{lxb_css_property_font_family_t}}(x + 0)
    f === :font_weight && return Ptr{Ptr{lxb_css_property_font_weight_t}}(x + 0)
    f === :font_stretch && return Ptr{Ptr{lxb_css_property_font_stretch_t}}(x + 0)
    f === :font_style && return Ptr{Ptr{lxb_css_property_font_style_t}}(x + 0)
    f === :font_size && return Ptr{Ptr{lxb_css_property_font_size_t}}(x + 0)
    f === :float_reference && return Ptr{Ptr{lxb_css_property_float_reference_t}}(x + 0)
    f === :floatp && return Ptr{Ptr{lxb_css_property_float_t}}(x + 0)
    f === :clear && return Ptr{Ptr{lxb_css_property_clear_t}}(x + 0)
    f === :float_defer && return Ptr{Ptr{lxb_css_property_float_defer_t}}(x + 0)
    f === :float_offset && return Ptr{Ptr{lxb_css_property_float_offset_t}}(x + 0)
    f === :wrap_flow && return Ptr{Ptr{lxb_css_property_wrap_flow_t}}(x + 0)
    f === :wrap_through && return Ptr{Ptr{lxb_css_property_wrap_through_t}}(x + 0)
    f === :flex_direction && return Ptr{Ptr{lxb_css_property_flex_direction_t}}(x + 0)
    f === :flex_wrap && return Ptr{Ptr{lxb_css_property_flex_wrap_t}}(x + 0)
    f === :flex_flow && return Ptr{Ptr{lxb_css_property_flex_flow_t}}(x + 0)
    f === :flex && return Ptr{Ptr{lxb_css_property_flex_t}}(x + 0)
    f === :flex_grow && return Ptr{Ptr{lxb_css_property_flex_grow_t}}(x + 0)
    f === :flex_shrink && return Ptr{Ptr{lxb_css_property_flex_shrink_t}}(x + 0)
    f === :flex_basis && return Ptr{Ptr{lxb_css_property_flex_basis_t}}(x + 0)
    f === :justify_content && return Ptr{Ptr{lxb_css_property_justify_content_t}}(x + 0)
    f === :align_items && return Ptr{Ptr{lxb_css_property_align_items_t}}(x + 0)
    f === :align_self && return Ptr{Ptr{lxb_css_property_align_self_t}}(x + 0)
    f === :align_content && return Ptr{Ptr{lxb_css_property_align_content_t}}(x + 0)
    f === :dominant_baseline && return Ptr{Ptr{lxb_css_property_dominant_baseline_t}}(x + 0)
    f === :vertical_align && return Ptr{Ptr{lxb_css_property_vertical_align_t}}(x + 0)
    f === :baseline_source && return Ptr{Ptr{lxb_css_property_baseline_source_t}}(x + 0)
    f === :alignment_baseline &&
        return Ptr{Ptr{lxb_css_property_alignment_baseline_t}}(x + 0)
    f === :baseline_shift && return Ptr{Ptr{lxb_css_property_baseline_shift_t}}(x + 0)
    f === :line_height && return Ptr{Ptr{lxb_css_property_line_height_t}}(x + 0)
    f === :z_index && return Ptr{Ptr{lxb_css_property_z_index_t}}(x + 0)
    f === :direction && return Ptr{Ptr{lxb_css_property_direction_t}}(x + 0)
    f === :unicode_bidi && return Ptr{Ptr{lxb_css_property_unicode_bidi_t}}(x + 0)
    f === :writing_mode && return Ptr{Ptr{lxb_css_property_writing_mode_t}}(x + 0)
    f === :text_orientation && return Ptr{Ptr{lxb_css_property_text_orientation_t}}(x + 0)
    f === :text_combine_upright &&
        return Ptr{Ptr{lxb_css_property_text_combine_upright_t}}(x + 0)
    f === :overflow_x && return Ptr{Ptr{lxb_css_property_overflow_x_t}}(x + 0)
    f === :overflow_y && return Ptr{Ptr{lxb_css_property_overflow_y_t}}(x + 0)
    f === :overflow_block && return Ptr{Ptr{lxb_css_property_overflow_block_t}}(x + 0)
    f === :overflow_inline && return Ptr{Ptr{lxb_css_property_overflow_inline_t}}(x + 0)
    f === :text_overflow && return Ptr{Ptr{lxb_css_property_text_overflow_t}}(x + 0)
    f === :text_decoration_line &&
        return Ptr{Ptr{lxb_css_property_text_decoration_line_t}}(x + 0)
    f === :text_decoration_style &&
        return Ptr{Ptr{lxb_css_property_text_decoration_style_t}}(x + 0)
    f === :text_decoration_color &&
        return Ptr{Ptr{lxb_css_property_text_decoration_color_t}}(x + 0)
    f === :text_decoration && return Ptr{Ptr{lxb_css_property_text_decoration_t}}(x + 0)
    f === :user && return Ptr{Ptr{Cvoid}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_278, f::Symbol)
    r = Ref{__JL_Ctag_278}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_278}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_278}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct lxb_css_rule_declaration
    data::NTuple{88,UInt8}
end

function Base.getproperty(x::Ptr{lxb_css_rule_declaration}, f::Symbol)
    f === :rule && return Ptr{lxb_css_rule_t}(x + 0)
    f === :type && return Ptr{Csize_t}(x + 64)
    f === :u && return Ptr{__JL_Ctag_278}(x + 72)
    f === :important && return Ptr{Bool}(x + 80)
    return getfield(x, f)
end

function Base.getproperty(x::lxb_css_rule_declaration, f::Symbol)
    r = Ref{lxb_css_rule_declaration}(x)
    ptr = Base.unsafe_convert(Ptr{lxb_css_rule_declaration}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{lxb_css_rule_declaration}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const lxb_css_rule_declaration_t = lxb_css_rule_declaration

# typedef const lxb_char_t * ( * lxb_html_tokenizer_state_f ) ( lxb_html_tokenizer_t * tkz , const lxb_char_t * data , const lxb_char_t * end )
const lxb_html_tokenizer_state_f = Ptr{Cvoid}

# typedef lxb_html_token_t * ( * lxb_html_tokenizer_token_f ) ( lxb_html_tokenizer_t * tkz , lxb_html_token_t * token , void * ctx )
const lxb_html_tokenizer_token_f = Ptr{Cvoid}

struct lxb_dom_attr_data_t
    entry::lexbor_hash_entry_t
    attr_id::lxb_dom_attr_id_t
    ref_count::Csize_t
    read_only::Bool
end

const lxb_html_token_attr_type_t = Cint

struct lxb_html_token_attr
    name_begin::Ptr{lxb_char_t}
    name_end::Ptr{lxb_char_t}
    value_begin::Ptr{lxb_char_t}
    value_end::Ptr{lxb_char_t}
    name::Ptr{lxb_dom_attr_data_t}
    value::Ptr{lxb_char_t}
    value_size::Csize_t
    next::Ptr{Cvoid} # next::Ptr{lxb_html_token_attr_t}
    prev::Ptr{Cvoid} # prev::Ptr{lxb_html_token_attr_t}
    type::lxb_html_token_attr_type_t
end

function Base.getproperty(x::lxb_html_token_attr, f::Symbol)
    f === :next && return Ptr{lxb_html_token_attr_t}(getfield(x, f))
    f === :prev && return Ptr{lxb_html_token_attr_t}(getfield(x, f))
    return getfield(x, f)
end

const lxb_html_token_attr_t = lxb_html_token_attr

const lxb_tag_id_t = Csize_t

const lxb_html_token_type_t = Cint

struct lxb_html_token_t
    _begin::Ptr{lxb_char_t}
    _end::Ptr{lxb_char_t}
    text_start::Ptr{lxb_char_t}
    text_end::Ptr{lxb_char_t}
    attr_first::Ptr{lxb_html_token_attr_t}
    attr_last::Ptr{lxb_html_token_attr_t}
    base_element::Ptr{Cvoid}
    null_count::Csize_t
    tag_id::lxb_tag_id_t
    type::lxb_html_token_type_t
end

struct lxb_html_tree_pending_table_t
    text_list::Ptr{lexbor_array_obj_t}
    have_non_ws::Bool
end

# typedef bool ( * lxb_html_tree_insertion_mode_f ) ( lxb_html_tree_t * tree , lxb_html_token_t * token )
const lxb_html_tree_insertion_mode_f = Ptr{Cvoid}

# typedef lxb_status_t ( * lxb_html_tree_append_attr_f ) ( lxb_html_tree_t * tree , lxb_dom_attr_t * attr , void * ctx )
const lxb_html_tree_append_attr_f = Ptr{Cvoid}

struct lxb_html_tree
    tkz_ref::Ptr{Cvoid} # tkz_ref::Ptr{lxb_html_tokenizer_t}
    document::Ptr{lxb_html_document_t}
    fragment::Ptr{lxb_dom_node_t}
    form::Ptr{lxb_html_form_element_t}
    open_elements::Ptr{lexbor_array_t}
    active_formatting::Ptr{lexbor_array_t}
    template_insertion_modes::Ptr{lexbor_array_obj_t}
    pending_table::lxb_html_tree_pending_table_t
    parse_errors::Ptr{lexbor_array_obj_t}
    foster_parenting::Bool
    frameset_ok::Bool
    scripting::Bool
    mode::lxb_html_tree_insertion_mode_f
    original_mode::lxb_html_tree_insertion_mode_f
    before_append_attr::lxb_html_tree_append_attr_f
    status::lxb_status_t
    ref_count::Csize_t
end

function Base.getproperty(x::lxb_html_tree, f::Symbol)
    f === :tkz_ref && return Ptr{lxb_html_tokenizer_t}(getfield(x, f))
    return getfield(x, f)
end

const lxb_html_tree_t = lxb_html_tree

struct lexbor_sbst_entry_static_t
    key::lxb_char_t
    value::Ptr{Cvoid}
    value_len::Csize_t
    left::Csize_t
    right::Csize_t
    next::Csize_t
end

const lxb_html_tokenizer_opt_t = Cuint

struct lxb_html_tokenizer
    state::lxb_html_tokenizer_state_f
    state_return::lxb_html_tokenizer_state_f
    callback_token_done::lxb_html_tokenizer_token_f
    callback_token_ctx::Ptr{Cvoid}
    tags::Ptr{lexbor_hash_t}
    attrs::Ptr{lexbor_hash_t}
    attrs_mraw::Ptr{lexbor_mraw_t}
    mraw::Ptr{lexbor_mraw_t}
    token::Ptr{lxb_html_token_t}
    dobj_token::Ptr{lexbor_dobject_t}
    dobj_token_attr::Ptr{lexbor_dobject_t}
    parse_errors::Ptr{lexbor_array_obj_t}
    tree::Ptr{lxb_html_tree_t}
    markup::Ptr{lxb_char_t}
    temp::Ptr{lxb_char_t}
    tmp_tag_id::lxb_tag_id_t
    start::Ptr{lxb_char_t}
    pos::Ptr{lxb_char_t}
    _end::Ptr{lxb_char_t}
    _begin::Ptr{lxb_char_t}
    last::Ptr{lxb_char_t}
    entity::Ptr{lexbor_sbst_entry_static_t}
    entity_match::Ptr{lexbor_sbst_entry_static_t}
    entity_start::Csize_t
    entity_end::Csize_t
    entity_length::UInt32
    entity_number::UInt32
    is_attribute::Bool
    opt::lxb_html_tokenizer_opt_t
    status::lxb_status_t
    is_eof::Bool
    base::Ptr{Cvoid} # base::Ptr{lxb_html_tokenizer_t}
    ref_count::Csize_t
end

function Base.getproperty(x::lxb_html_tokenizer, f::Symbol)
    f === :base && return Ptr{lxb_html_tokenizer_t}(getfield(x, f))
    return getfield(x, f)
end

const lxb_html_tokenizer_t = lxb_html_tokenizer

struct lxb_tag_data_t
    entry::lexbor_hash_entry_t
    tag_id::lxb_tag_id_t
    ref_count::Csize_t
    read_only::Bool
end

const lxb_codepoint_t = UInt32

# typedef lxb_status_t ( * lexbor_callback_f ) ( const lxb_char_t * buffer , size_t size , void * ctx )
const lexbor_callback_f = Ptr{Cvoid}

# typedef void * ( * lexbor_memory_malloc_f ) ( size_t size )
const lexbor_memory_malloc_f = Ptr{Cvoid}

# typedef void * ( * lexbor_memory_realloc_f ) ( void * dst , size_t size )
const lexbor_memory_realloc_f = Ptr{Cvoid}

# typedef void * ( * lexbor_memory_calloc_f ) ( size_t num , size_t size )
const lexbor_memory_calloc_f = Ptr{Cvoid}

# typedef void ( * lexbor_memory_free_f ) ( void * dst )
const lexbor_memory_free_f = Ptr{Cvoid}

@cenum lexbor_status_t::UInt32 begin
    LXB_STATUS_OK = 0
    LXB_STATUS_ERROR = 1
    LXB_STATUS_ERROR_MEMORY_ALLOCATION = 2
    LXB_STATUS_ERROR_OBJECT_IS_NULL = 3
    LXB_STATUS_ERROR_SMALL_BUFFER = 4
    LXB_STATUS_ERROR_INCOMPLETE_OBJECT = 5
    LXB_STATUS_ERROR_NO_FREE_SLOT = 6
    LXB_STATUS_ERROR_TOO_SMALL_SIZE = 7
    LXB_STATUS_ERROR_NOT_EXISTS = 8
    LXB_STATUS_ERROR_WRONG_ARGS = 9
    LXB_STATUS_ERROR_WRONG_STAGE = 10
    LXB_STATUS_ERROR_UNEXPECTED_RESULT = 11
    LXB_STATUS_ERROR_UNEXPECTED_DATA = 12
    LXB_STATUS_ERROR_OVERFLOW = 13
    LXB_STATUS_CONTINUE = 14
    LXB_STATUS_SMALL_BUFFER = 15
    LXB_STATUS_ABORTED = 16
    LXB_STATUS_STOPPED = 17
    LXB_STATUS_NEXT = 18
    LXB_STATUS_STOP = 19
    LXB_STATUS_WARNING = 20
end

@cenum lexbor_action_t::UInt32 begin
    LEXBOR_ACTION_OK = 0
    LEXBOR_ACTION_STOP = 1
    LEXBOR_ACTION_NEXT = 2
end

# typedef lxb_status_t ( * lexbor_serialize_cb_f ) ( const lxb_char_t * data , size_t len , void * ctx )
const lexbor_serialize_cb_f = Ptr{Cvoid}

# typedef lxb_status_t ( * lexbor_serialize_cb_cp_f ) ( const lxb_codepoint_t * cps , size_t len , void * ctx )
const lexbor_serialize_cb_cp_f = Ptr{Cvoid}

struct lexbor_serialize_ctx_t
    cb::lexbor_serialize_cb_f
    ctx::Ptr{Cvoid}
    opt::intptr_t
    count::Csize_t
end

@cenum lxb_html_status_t::UInt32 begin
    LXB_HTML_STATUS_OK = 0
end

# typedef bool ( * lexbor_bst_entry_f ) ( lexbor_bst_t * bst , lexbor_bst_entry_t * entry , void * ctx )
const lexbor_bst_entry_f = Ptr{Cvoid}

# typedef uint32_t ( * lexbor_hash_id_f ) ( const lxb_char_t * key , size_t size )
const lexbor_hash_id_f = Ptr{Cvoid}

# typedef bool ( * lexbor_hash_cmp_f ) ( const lxb_char_t * first , const lxb_char_t * second , size_t size )
const lexbor_hash_cmp_f = Ptr{Cvoid}

struct lexbor_hash_search
    hash::lexbor_hash_id_f
    cmp::lexbor_hash_cmp_f
end

const lexbor_hash_search_t = lexbor_hash_search

# typedef lxb_status_t ( * lexbor_hash_copy_f ) ( lexbor_hash_t * hash , lexbor_hash_entry_t * entry , const lxb_char_t * key , size_t size )
const lexbor_hash_copy_f = Ptr{Cvoid}

struct lexbor_hash_insert
    hash::lexbor_hash_id_f
    cmp::lexbor_hash_cmp_f
    copy::lexbor_hash_copy_f
end

const lexbor_hash_insert_t = lexbor_hash_insert

struct lexbor_shs_entry_t
    key::Cstring
    value::Ptr{Cvoid}
    key_len::Csize_t
    next::Csize_t
end

struct lexbor_shs_hash_t
    key::UInt32
    value::Ptr{Cvoid}
    next::Csize_t
end

const lxb_ns_id_t = Csize_t

const lxb_ns_prefix_id_t = Csize_t

@cenum lxb_ns_id_enum_t::UInt32 begin
    LXB_NS__UNDEF = 0
    LXB_NS__ANY = 1
    LXB_NS_HTML = 2
    LXB_NS_MATH = 3
    LXB_NS_SVG = 4
    LXB_NS_XLINK = 5
    LXB_NS_XML = 6
    LXB_NS_XMLNS = 7
    LXB_NS__LAST_ENTRY = 8
end

struct lxb_ns_data_t
    entry::lexbor_hash_entry_t
    ns_id::lxb_ns_id_t
    ref_count::Csize_t
    read_only::Bool
end

struct lxb_ns_prefix_data_t
    entry::lexbor_hash_entry_t
    prefix_id::lxb_ns_prefix_id_t
    ref_count::Csize_t
    read_only::Bool
end

@cenum lxb_tag_id_enum_t::UInt32 begin
    LXB_TAG__UNDEF = 0
    LXB_TAG__END_OF_FILE = 1
    LXB_TAG__TEXT = 2
    LXB_TAG__DOCUMENT = 3
    LXB_TAG__EM_COMMENT = 4
    LXB_TAG__EM_DOCTYPE = 5
    LXB_TAG_A = 6
    LXB_TAG_ABBR = 7
    LXB_TAG_ACRONYM = 8
    LXB_TAG_ADDRESS = 9
    LXB_TAG_ALTGLYPH = 10
    LXB_TAG_ALTGLYPHDEF = 11
    LXB_TAG_ALTGLYPHITEM = 12
    LXB_TAG_ANIMATECOLOR = 13
    LXB_TAG_ANIMATEMOTION = 14
    LXB_TAG_ANIMATETRANSFORM = 15
    LXB_TAG_ANNOTATION_XML = 16
    LXB_TAG_APPLET = 17
    LXB_TAG_AREA = 18
    LXB_TAG_ARTICLE = 19
    LXB_TAG_ASIDE = 20
    LXB_TAG_AUDIO = 21
    LXB_TAG_B = 22
    LXB_TAG_BASE = 23
    LXB_TAG_BASEFONT = 24
    LXB_TAG_BDI = 25
    LXB_TAG_BDO = 26
    LXB_TAG_BGSOUND = 27
    LXB_TAG_BIG = 28
    LXB_TAG_BLINK = 29
    LXB_TAG_BLOCKQUOTE = 30
    LXB_TAG_BODY = 31
    LXB_TAG_BR = 32
    LXB_TAG_BUTTON = 33
    LXB_TAG_CANVAS = 34
    LXB_TAG_CAPTION = 35
    LXB_TAG_CENTER = 36
    LXB_TAG_CITE = 37
    LXB_TAG_CLIPPATH = 38
    LXB_TAG_CODE = 39
    LXB_TAG_COL = 40
    LXB_TAG_COLGROUP = 41
    LXB_TAG_DATA = 42
    LXB_TAG_DATALIST = 43
    LXB_TAG_DD = 44
    LXB_TAG_DEL = 45
    LXB_TAG_DESC = 46
    LXB_TAG_DETAILS = 47
    LXB_TAG_DFN = 48
    LXB_TAG_DIALOG = 49
    LXB_TAG_DIR = 50
    LXB_TAG_DIV = 51
    LXB_TAG_DL = 52
    LXB_TAG_DT = 53
    LXB_TAG_EM = 54
    LXB_TAG_EMBED = 55
    LXB_TAG_FEBLEND = 56
    LXB_TAG_FECOLORMATRIX = 57
    LXB_TAG_FECOMPONENTTRANSFER = 58
    LXB_TAG_FECOMPOSITE = 59
    LXB_TAG_FECONVOLVEMATRIX = 60
    LXB_TAG_FEDIFFUSELIGHTING = 61
    LXB_TAG_FEDISPLACEMENTMAP = 62
    LXB_TAG_FEDISTANTLIGHT = 63
    LXB_TAG_FEDROPSHADOW = 64
    LXB_TAG_FEFLOOD = 65
    LXB_TAG_FEFUNCA = 66
    LXB_TAG_FEFUNCB = 67
    LXB_TAG_FEFUNCG = 68
    LXB_TAG_FEFUNCR = 69
    LXB_TAG_FEGAUSSIANBLUR = 70
    LXB_TAG_FEIMAGE = 71
    LXB_TAG_FEMERGE = 72
    LXB_TAG_FEMERGENODE = 73
    LXB_TAG_FEMORPHOLOGY = 74
    LXB_TAG_FEOFFSET = 75
    LXB_TAG_FEPOINTLIGHT = 76
    LXB_TAG_FESPECULARLIGHTING = 77
    LXB_TAG_FESPOTLIGHT = 78
    LXB_TAG_FETILE = 79
    LXB_TAG_FETURBULENCE = 80
    LXB_TAG_FIELDSET = 81
    LXB_TAG_FIGCAPTION = 82
    LXB_TAG_FIGURE = 83
    LXB_TAG_FONT = 84
    LXB_TAG_FOOTER = 85
    LXB_TAG_FOREIGNOBJECT = 86
    LXB_TAG_FORM = 87
    LXB_TAG_FRAME = 88
    LXB_TAG_FRAMESET = 89
    LXB_TAG_GLYPHREF = 90
    LXB_TAG_H1 = 91
    LXB_TAG_H2 = 92
    LXB_TAG_H3 = 93
    LXB_TAG_H4 = 94
    LXB_TAG_H5 = 95
    LXB_TAG_H6 = 96
    LXB_TAG_HEAD = 97
    LXB_TAG_HEADER = 98
    LXB_TAG_HGROUP = 99
    LXB_TAG_HR = 100
    LXB_TAG_HTML = 101
    LXB_TAG_I = 102
    LXB_TAG_IFRAME = 103
    LXB_TAG_IMAGE = 104
    LXB_TAG_IMG = 105
    LXB_TAG_INPUT = 106
    LXB_TAG_INS = 107
    LXB_TAG_ISINDEX = 108
    LXB_TAG_KBD = 109
    LXB_TAG_KEYGEN = 110
    LXB_TAG_LABEL = 111
    LXB_TAG_LEGEND = 112
    LXB_TAG_LI = 113
    LXB_TAG_LINEARGRADIENT = 114
    LXB_TAG_LINK = 115
    LXB_TAG_LISTING = 116
    LXB_TAG_MAIN = 117
    LXB_TAG_MALIGNMARK = 118
    LXB_TAG_MAP = 119
    LXB_TAG_MARK = 120
    LXB_TAG_MARQUEE = 121
    LXB_TAG_MATH = 122
    LXB_TAG_MENU = 123
    LXB_TAG_META = 124
    LXB_TAG_METER = 125
    LXB_TAG_MFENCED = 126
    LXB_TAG_MGLYPH = 127
    LXB_TAG_MI = 128
    LXB_TAG_MN = 129
    LXB_TAG_MO = 130
    LXB_TAG_MS = 131
    LXB_TAG_MTEXT = 132
    LXB_TAG_MULTICOL = 133
    LXB_TAG_NAV = 134
    LXB_TAG_NEXTID = 135
    LXB_TAG_NOBR = 136
    LXB_TAG_NOEMBED = 137
    LXB_TAG_NOFRAMES = 138
    LXB_TAG_NOSCRIPT = 139
    LXB_TAG_OBJECT = 140
    LXB_TAG_OL = 141
    LXB_TAG_OPTGROUP = 142
    LXB_TAG_OPTION = 143
    LXB_TAG_OUTPUT = 144
    LXB_TAG_P = 145
    LXB_TAG_PARAM = 146
    LXB_TAG_PATH = 147
    LXB_TAG_PICTURE = 148
    LXB_TAG_PLAINTEXT = 149
    LXB_TAG_PRE = 150
    LXB_TAG_PROGRESS = 151
    LXB_TAG_Q = 152
    LXB_TAG_RADIALGRADIENT = 153
    LXB_TAG_RB = 154
    LXB_TAG_RP = 155
    LXB_TAG_RT = 156
    LXB_TAG_RTC = 157
    LXB_TAG_RUBY = 158
    LXB_TAG_S = 159
    LXB_TAG_SAMP = 160
    LXB_TAG_SCRIPT = 161
    LXB_TAG_SECTION = 162
    LXB_TAG_SELECT = 163
    LXB_TAG_SLOT = 164
    LXB_TAG_SMALL = 165
    LXB_TAG_SOURCE = 166
    LXB_TAG_SPACER = 167
    LXB_TAG_SPAN = 168
    LXB_TAG_STRIKE = 169
    LXB_TAG_STRONG = 170
    LXB_TAG_STYLE = 171
    LXB_TAG_SUB = 172
    LXB_TAG_SUMMARY = 173
    LXB_TAG_SUP = 174
    LXB_TAG_SVG = 175
    LXB_TAG_TABLE = 176
    LXB_TAG_TBODY = 177
    LXB_TAG_TD = 178
    LXB_TAG_TEMPLATE = 179
    LXB_TAG_TEXTAREA = 180
    LXB_TAG_TEXTPATH = 181
    LXB_TAG_TFOOT = 182
    LXB_TAG_TH = 183
    LXB_TAG_THEAD = 184
    LXB_TAG_TIME = 185
    LXB_TAG_TITLE = 186
    LXB_TAG_TR = 187
    LXB_TAG_TRACK = 188
    LXB_TAG_TT = 189
    LXB_TAG_U = 190
    LXB_TAG_UL = 191
    LXB_TAG_VAR = 192
    LXB_TAG_VIDEO = 193
    LXB_TAG_WBR = 194
    LXB_TAG_XMP = 195
    LXB_TAG__LAST_ENTRY = 196
end

@cenum lxb_dom_exception_code_t::UInt32 begin
    LXB_DOM_INDEX_SIZE_ERR = 0
    LXB_DOM_DOMSTRING_SIZE_ERR = 1
    LXB_DOM_HIERARCHY_REQUEST_ERR = 2
    LXB_DOM_WRONG_DOCUMENT_ERR = 3
    LXB_DOM_INVALID_CHARACTER_ERR = 4
    LXB_DOM_NO_DATA_ALLOWED_ERR = 5
    LXB_DOM_NO_MODIFICATION_ALLOWED_ERR = 6
    LXB_DOM_NOT_FOUND_ERR = 7
    LXB_DOM_NOT_SUPPORTED_ERR = 8
    LXB_DOM_INUSE_ATTRIBUTE_ERR = 9
    LXB_DOM_INVALID_STATE_ERR = 10
    LXB_DOM_SYNTAX_ERR = 11
    LXB_DOM_INVALID_MODIFICATION_ERR = 12
    LXB_DOM_NAMESPACE_ERR = 13
    LXB_DOM_INVALID_ACCESS_ERR = 14
    LXB_DOM_VALIDATION_ERR = 15
    LXB_DOM_TYPE_MISMATCH_ERR = 16
    LXB_DOM_SECURITY_ERR = 17
    LXB_DOM_NETWORK_ERR = 18
    LXB_DOM_ABORT_ERR = 19
    LXB_DOM_URL_MISMATCH_ERR = 20
    LXB_DOM_QUOTA_EXCEEDED_ERR = 21
    LXB_DOM_TIMEOUT_ERR = 22
    LXB_DOM_INVALID_NODE_TYPE_ERR = 23
    LXB_DOM_DATA_CLONE_ERR = 24
end

const lxb_dom_interface_t = Cvoid

# typedef void * ( * lxb_dom_interface_constructor_f ) ( void * document )
const lxb_dom_interface_constructor_f = Ptr{Cvoid}

# typedef void * ( * lxb_dom_interface_destructor_f ) ( void * intrfc )
const lxb_dom_interface_destructor_f = Ptr{Cvoid}

struct lxb_dom_collection_t
    array::lexbor_array_t
    document::Ptr{lxb_dom_document_t}
end

# typedef lexbor_action_t ( * lxb_dom_node_simple_walker_f ) ( lxb_dom_node_t * node , void * ctx )
const lxb_dom_node_simple_walker_f = Ptr{Cvoid}

function lxb_dom_node_text_content(node, len)
    @ccall liblexbor.lxb_dom_node_text_content(
        node::Ptr{lxb_dom_node_t},
        len::Ptr{Csize_t},
    )::Ptr{lxb_char_t}
end

function lxb_dom_node_next_noi(node)
    @ccall liblexbor.lxb_dom_node_next_noi(node::Ptr{lxb_dom_node_t})::Ptr{lxb_dom_node_t}
end

function lxb_dom_node_prev_noi(node)
    @ccall liblexbor.lxb_dom_node_prev_noi(node::Ptr{lxb_dom_node_t})::Ptr{lxb_dom_node_t}
end

function lxb_dom_node_first_child_noi(node)
    @ccall liblexbor.lxb_dom_node_first_child_noi(
        node::Ptr{lxb_dom_node_t},
    )::Ptr{lxb_dom_node_t}
end

@cenum lxb_dom_attr_id_enum_t::UInt32 begin
    LXB_DOM_ATTR__UNDEF = 0
    LXB_DOM_ATTR_ACTIVE = 1
    LXB_DOM_ATTR_ALT = 2
    LXB_DOM_ATTR_CHARSET = 3
    LXB_DOM_ATTR_CHECKED = 4
    LXB_DOM_ATTR_CLASS = 5
    LXB_DOM_ATTR_COLOR = 6
    LXB_DOM_ATTR_CONTENT = 7
    LXB_DOM_ATTR_DIR = 8
    LXB_DOM_ATTR_DISABLED = 9
    LXB_DOM_ATTR_FACE = 10
    LXB_DOM_ATTR_FOCUS = 11
    LXB_DOM_ATTR_FOR = 12
    LXB_DOM_ATTR_HEIGHT = 13
    LXB_DOM_ATTR_HOVER = 14
    LXB_DOM_ATTR_HREF = 15
    LXB_DOM_ATTR_HTML = 16
    LXB_DOM_ATTR_HTTP_EQUIV = 17
    LXB_DOM_ATTR_ID = 18
    LXB_DOM_ATTR_IS = 19
    LXB_DOM_ATTR_MAXLENGTH = 20
    LXB_DOM_ATTR_PLACEHOLDER = 21
    LXB_DOM_ATTR_POOL = 22
    LXB_DOM_ATTR_PUBLIC = 23
    LXB_DOM_ATTR_READONLY = 24
    LXB_DOM_ATTR_REQUIRED = 25
    LXB_DOM_ATTR_SCHEME = 26
    LXB_DOM_ATTR_SELECTED = 27
    LXB_DOM_ATTR_SIZE = 28
    LXB_DOM_ATTR_SLOT = 29
    LXB_DOM_ATTR_SRC = 30
    LXB_DOM_ATTR_STYLE = 31
    LXB_DOM_ATTR_SYSTEM = 32
    LXB_DOM_ATTR_TITLE = 33
    LXB_DOM_ATTR_TYPE = 34
    LXB_DOM_ATTR_WIDTH = 35
    LXB_DOM_ATTR__LAST_ENTRY = 36
end

function lxb_dom_attr_qualified_name(attr, len)
    @ccall liblexbor.lxb_dom_attr_qualified_name(
        attr::Ptr{lxb_dom_attr_t},
        len::Ptr{Csize_t},
    )::Ptr{lxb_char_t}
end

function lxb_dom_attr_value_noi(attr, len)
    @ccall liblexbor.lxb_dom_attr_value_noi(
        attr::Ptr{lxb_dom_attr_t},
        len::Ptr{Csize_t},
    )::Ptr{lxb_char_t}
end

@cenum lxb_html_token_attr_type::UInt32 begin
    LXB_HTML_TOKEN_ATTR_TYPE_UNDEF = 0
    LXB_HTML_TOKEN_ATTR_TYPE_NAME_NULL = 1
    LXB_HTML_TOKEN_ATTR_TYPE_VALUE_NULL = 2
end

function lxb_tag_name_by_id_noi(hash, tag_id, len)
    @ccall liblexbor.lxb_tag_name_by_id_noi(
        hash::Ptr{lexbor_hash_t},
        tag_id::lxb_tag_id_t,
        len::Ptr{Csize_t},
    )::Ptr{lxb_char_t}
end

@cenum lxb_html_token_type::UInt32 begin
    LXB_HTML_TOKEN_TYPE_OPEN = 0
    LXB_HTML_TOKEN_TYPE_CLOSE = 1
    LXB_HTML_TOKEN_TYPE_CLOSE_SELF = 2
    LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS = 4
    LXB_HTML_TOKEN_TYPE_DONE = 8
end

@cenum lxb_html_tree_error_id_t::UInt32 begin
    LXB_HTML_RULES_ERROR_UNTO = 0
    LXB_HTML_RULES_ERROR_UNCLTO = 1
    LXB_HTML_RULES_ERROR_NUCH = 2
    LXB_HTML_RULES_ERROR_UNCHTO = 3
    LXB_HTML_RULES_ERROR_UNTOININMO = 4
    LXB_HTML_RULES_ERROR_BADOTOININMO = 5
    LXB_HTML_RULES_ERROR_DOTOINBEHTMO = 6
    LXB_HTML_RULES_ERROR_UNCLTOINBEHTMO = 7
    LXB_HTML_RULES_ERROR_DOTOINBEHEMO = 8
    LXB_HTML_RULES_ERROR_UNCLTOINBEHEMO = 9
    LXB_HTML_RULES_ERROR_DOTOINHEMO = 10
    LXB_HTML_RULES_ERROR_NOVOHTELSTTAWITRSO = 11
    LXB_HTML_RULES_ERROR_HETOINHEMO = 12
    LXB_HTML_RULES_ERROR_UNCLTOINHEMO = 13
    LXB_HTML_RULES_ERROR_TECLTOWIOPINHEMO = 14
    LXB_HTML_RULES_ERROR_TEELISNOCUINHEMO = 15
    LXB_HTML_RULES_ERROR_DOTOINHENOMO = 16
    LXB_HTML_RULES_ERROR_DOTOAFHEMO = 17
    LXB_HTML_RULES_ERROR_HETOAFHEMO = 18
    LXB_HTML_RULES_ERROR_DOTOINBOMO = 19
    LXB_HTML_RULES_ERROR_BAENOPELISWR = 20
    LXB_HTML_RULES_ERROR_OPELISWR = 21
    LXB_HTML_RULES_ERROR_UNELINOPELST = 22
    LXB_HTML_RULES_ERROR_MIELINOPELST = 23
    LXB_HTML_RULES_ERROR_NOBOELINSC = 24
    LXB_HTML_RULES_ERROR_MIELINSC = 25
    LXB_HTML_RULES_ERROR_UNELINSC = 26
    LXB_HTML_RULES_ERROR_UNELINACFOST = 27
    LXB_HTML_RULES_ERROR_UNENOFFI = 28
    LXB_HTML_RULES_ERROR_CHINTATE = 29
    LXB_HTML_RULES_ERROR_DOTOINTAMO = 30
    LXB_HTML_RULES_ERROR_DOTOINSEMO = 31
    LXB_HTML_RULES_ERROR_DOTOAFBOMO = 32
    LXB_HTML_RULES_ERROR_DOTOINFRMO = 33
    LXB_HTML_RULES_ERROR_DOTOAFFRMO = 34
    LXB_HTML_RULES_ERROR_DOTOFOCOMO = 35
    LXB_HTML_RULES_ERROR_LAST_ENTRY = 36
end

struct lxb_html_tree_error_t
    id::lxb_html_tree_error_id_t
    _begin::Ptr{lxb_char_t}
    _end::Ptr{lxb_char_t}
end

@cenum lxb_html_tokenizer_error_id_t::UInt32 begin
    LXB_HTML_TOKENIZER_ERROR_ABCLOFEMCO = 0
    LXB_HTML_TOKENIZER_ERROR_ABDOPUID = 1
    LXB_HTML_TOKENIZER_ERROR_ABDOSYID = 2
    LXB_HTML_TOKENIZER_ERROR_ABOFDIINNUCHRE = 3
    LXB_HTML_TOKENIZER_ERROR_CDINHTCO = 4
    LXB_HTML_TOKENIZER_ERROR_CHREOUUNRA = 5
    LXB_HTML_TOKENIZER_ERROR_COCHININST = 6
    LXB_HTML_TOKENIZER_ERROR_COCHRE = 7
    LXB_HTML_TOKENIZER_ERROR_ENTAWIAT = 8
    LXB_HTML_TOKENIZER_ERROR_DUAT = 9
    LXB_HTML_TOKENIZER_ERROR_ENTAWITRSO = 10
    LXB_HTML_TOKENIZER_ERROR_EOBETANA = 11
    LXB_HTML_TOKENIZER_ERROR_EOINCD = 12
    LXB_HTML_TOKENIZER_ERROR_EOINCO = 13
    LXB_HTML_TOKENIZER_ERROR_EOINDO = 14
    LXB_HTML_TOKENIZER_ERROR_EOINSCHTCOLITE = 15
    LXB_HTML_TOKENIZER_ERROR_EOINTA = 16
    LXB_HTML_TOKENIZER_ERROR_INCLCO = 17
    LXB_HTML_TOKENIZER_ERROR_INOPCO = 18
    LXB_HTML_TOKENIZER_ERROR_INCHSEAFDONA = 19
    LXB_HTML_TOKENIZER_ERROR_INFICHOFTANA = 20
    LXB_HTML_TOKENIZER_ERROR_MIATVA = 21
    LXB_HTML_TOKENIZER_ERROR_MIDONA = 22
    LXB_HTML_TOKENIZER_ERROR_MIDOPUID = 23
    LXB_HTML_TOKENIZER_ERROR_MIDOSYID = 24
    LXB_HTML_TOKENIZER_ERROR_MIENTANA = 25
    LXB_HTML_TOKENIZER_ERROR_MIQUBEDOPUID = 26
    LXB_HTML_TOKENIZER_ERROR_MIQUBEDOSYID = 27
    LXB_HTML_TOKENIZER_ERROR_MISEAFCHRE = 28
    LXB_HTML_TOKENIZER_ERROR_MIWHAFDOPUKE = 29
    LXB_HTML_TOKENIZER_ERROR_MIWHAFDOSYKE = 30
    LXB_HTML_TOKENIZER_ERROR_MIWHBEDONA = 31
    LXB_HTML_TOKENIZER_ERROR_MIWHBEAT = 32
    LXB_HTML_TOKENIZER_ERROR_MIWHBEDOPUANSYID = 33
    LXB_HTML_TOKENIZER_ERROR_NECO = 34
    LXB_HTML_TOKENIZER_ERROR_NOCHRE = 35
    LXB_HTML_TOKENIZER_ERROR_NOININST = 36
    LXB_HTML_TOKENIZER_ERROR_NOVOHTELSTTAWITRSO = 37
    LXB_HTML_TOKENIZER_ERROR_NUCHRE = 38
    LXB_HTML_TOKENIZER_ERROR_SUCHRE = 39
    LXB_HTML_TOKENIZER_ERROR_SUININST = 40
    LXB_HTML_TOKENIZER_ERROR_UNCHAFDOSYID = 41
    LXB_HTML_TOKENIZER_ERROR_UNCHINATNA = 42
    LXB_HTML_TOKENIZER_ERROR_UNCHINUNATVA = 43
    LXB_HTML_TOKENIZER_ERROR_UNEQSIBEATNA = 44
    LXB_HTML_TOKENIZER_ERROR_UNNUCH = 45
    LXB_HTML_TOKENIZER_ERROR_UNQUMAINOFTANA = 46
    LXB_HTML_TOKENIZER_ERROR_UNSOINTA = 47
    LXB_HTML_TOKENIZER_ERROR_UNNACHRE = 48
    LXB_HTML_TOKENIZER_ERROR_LAST_ENTRY = 49
end

struct lxb_html_tokenizer_error_t
    pos::Ptr{lxb_char_t}
    id::lxb_html_tokenizer_error_id_t
end

function lxb_html_tokenizer_create()
    @ccall liblexbor.lxb_html_tokenizer_create()::Ptr{lxb_html_tokenizer_t}
end

function lxb_html_tokenizer_init(tkz)
    @ccall liblexbor.lxb_html_tokenizer_init(tkz::Ptr{lxb_html_tokenizer_t})::lxb_status_t
end

function lxb_html_tokenizer_destroy(tkz)
    @ccall liblexbor.lxb_html_tokenizer_destroy(
        tkz::Ptr{lxb_html_tokenizer_t},
    )::Ptr{lxb_html_tokenizer_t}
end

function lxb_html_tokenizer_begin(tkz)
    @ccall liblexbor.lxb_html_tokenizer_begin(tkz::Ptr{lxb_html_tokenizer_t})::lxb_status_t
end

function lxb_html_tokenizer_chunk(tkz, data, size)
    @ccall liblexbor.lxb_html_tokenizer_chunk(
        tkz::Ptr{lxb_html_tokenizer_t},
        data::Ptr{lxb_char_t},
        size::Csize_t,
    )::lxb_status_t
end

function lxb_html_tokenizer_end(tkz)
    @ccall liblexbor.lxb_html_tokenizer_end(tkz::Ptr{lxb_html_tokenizer_t})::lxb_status_t
end

function lxb_html_tokenizer_callback_token_done_set_noi(tkz, call_func, ctx)
    @ccall liblexbor.lxb_html_tokenizer_callback_token_done_set_noi(
        tkz::Ptr{lxb_html_tokenizer_t},
        call_func::lxb_html_tokenizer_token_f,
        ctx::Ptr{Cvoid},
    )::Cvoid
end

function lxb_html_tokenizer_tags_noi(tkz)
    @ccall liblexbor.lxb_html_tokenizer_tags_noi(
        tkz::Ptr{lxb_html_tokenizer_t},
    )::Ptr{lexbor_hash_t}
end

# typedef lxb_status_t ( * lexbor_avl_node_f ) ( lexbor_avl_t * avl , lexbor_avl_node_t * * root , lexbor_avl_node_t * node , void * ctx )
const lexbor_avl_node_f = Ptr{Cvoid}

const lxb_css_type_t = UInt32

struct lxb_css_parser_error
    message::lexbor_str_t
end

const lxb_css_parser_error_t = lxb_css_parser_error

# typedef void * ( * lxb_css_style_create_f ) ( lxb_css_memory_t * memory )
const lxb_css_style_create_f = Ptr{Cvoid}

# typedef lxb_status_t ( * lxb_css_style_serialize_f ) ( const void * style , lexbor_serialize_cb_f cb , void * ctx )
const lxb_css_style_serialize_f = Ptr{Cvoid}

# typedef void * ( * lxb_css_style_destroy_f ) ( lxb_css_memory_t * memory , void * style , bool self_destroy )
const lxb_css_style_destroy_f = Ptr{Cvoid}

struct lxb_css_entry_data_t
    name::Ptr{lxb_char_t}
    length::Csize_t
    unique::Csize_t
    state::lxb_css_parser_state_f
    create::lxb_css_style_create_f
    destroy::lxb_css_style_destroy_f
    serialize::lxb_css_style_serialize_f
    initial::Ptr{Cvoid}
end

struct lxb_css_data_t
    name::Ptr{lxb_char_t}
    length::Csize_t
    unique::Csize_t
end

@cenum lxb_css_log_type_t::UInt32 begin
    LXB_CSS_LOG_INFO = 0
    LXB_CSS_LOG_WARNING = 1
    LXB_CSS_LOG_ERROR = 2
    LXB_CSS_LOG_SYNTAX_ERROR = 3
end

struct lxb_css_log_message_t
    text::lexbor_str_t
    type::lxb_css_log_type_t
end

# typedef lxb_status_t ( * lxb_css_syntax_token_cb_f ) ( const lxb_char_t * data , size_t len , void * ctx )
const lxb_css_syntax_token_cb_f = Ptr{Cvoid}

const lxb_css_syntax_token_terminated_t = lxb_css_syntax_token_base_t

# typedef const lxb_char_t * ( * lxb_css_syntax_tokenizer_state_f ) ( lxb_css_syntax_tokenizer_t * tkz , lxb_css_syntax_token_t * token , const lxb_char_t * data , const lxb_char_t * end )
const lxb_css_syntax_tokenizer_state_f = Ptr{Cvoid}

@cenum lxb_css_syntax_tokenizer_opt::UInt32 begin
    LXB_CSS_SYNTAX_TOKENIZER_OPT_UNDEF = 0
end

# typedef lxb_status_t ( * lxb_css_syntax_declaration_end_f ) ( lxb_css_parser_t * parser , void * ctx , bool important , bool failed )
const lxb_css_syntax_declaration_end_f = Ptr{Cvoid}

# typedef lxb_status_t ( * lxb_css_syntax_cb_done_f ) ( lxb_css_parser_t * parser , const lxb_css_syntax_token_t * token , void * ctx , bool failed )
const lxb_css_syntax_cb_done_f = Ptr{Cvoid}

struct lxb_css_syntax_list_rules_offset_t
    _begin::Csize_t
    _end::Csize_t
end

struct lxb_css_syntax_at_rule_offset_t
    name::Csize_t
    prelude::Csize_t
    prelude_end::Csize_t
    block::Csize_t
    block_end::Csize_t
end

struct lxb_css_syntax_qualified_offset_t
    prelude::Csize_t
    prelude_end::Csize_t
    block::Csize_t
    block_end::Csize_t
end

struct lxb_css_syntax_declarations_offset_t
    _begin::Csize_t
    _end::Csize_t
    name_begin::Csize_t
    name_end::Csize_t
    value_begin::Csize_t
    before_important::Csize_t
    value_end::Csize_t
end

struct lxb_css_syntax_cb_base_t
    state::lxb_css_parser_state_f
    block::lxb_css_parser_state_f
    failed::lxb_css_parser_state_f
    _end::lxb_css_syntax_cb_done_f
end

const lxb_css_syntax_cb_pipe_t = lxb_css_syntax_cb_base_t

const lxb_css_syntax_cb_block_t = lxb_css_syntax_cb_base_t

const lxb_css_syntax_cb_function_t = lxb_css_syntax_cb_base_t

const lxb_css_syntax_cb_components_t = lxb_css_syntax_cb_base_t

const lxb_css_syntax_cb_at_rule_t = lxb_css_syntax_cb_base_t

const lxb_css_syntax_cb_qualified_rule_t = lxb_css_syntax_cb_base_t

struct lxb_css_syntax_cb_declarations_t
    cb::lxb_css_syntax_cb_base_t
    declaration_end::lxb_css_syntax_declaration_end_f
    at_rule::Ptr{lxb_css_syntax_cb_at_rule_t}
end

struct lxb_css_syntax_cb_list_rules_t
    cb::lxb_css_syntax_cb_base_t
    next::lxb_css_parser_state_f
    at_rule::Ptr{lxb_css_syntax_cb_at_rule_t}
    qualified_rule::Ptr{lxb_css_syntax_cb_qualified_rule_t}
end

@cenum __JL_Ctag_50::UInt32 begin
    LXB_CSS_VALUE__UNDEF = 0
    LXB_CSS_VALUE_INITIAL = 1
    LXB_CSS_VALUE_INHERIT = 2
    LXB_CSS_VALUE_UNSET = 3
    LXB_CSS_VALUE_REVERT = 4
    LXB_CSS_VALUE_FLEX_START = 5
    LXB_CSS_VALUE_FLEX_END = 6
    LXB_CSS_VALUE_CENTER = 7
    LXB_CSS_VALUE_SPACE_BETWEEN = 8
    LXB_CSS_VALUE_SPACE_AROUND = 9
    LXB_CSS_VALUE_STRETCH = 10
    LXB_CSS_VALUE_BASELINE = 11
    LXB_CSS_VALUE_AUTO = 12
    LXB_CSS_VALUE_TEXT_BOTTOM = 13
    LXB_CSS_VALUE_ALPHABETIC = 14
    LXB_CSS_VALUE_IDEOGRAPHIC = 15
    LXB_CSS_VALUE_MIDDLE = 16
    LXB_CSS_VALUE_CENTRAL = 17
    LXB_CSS_VALUE_MATHEMATICAL = 18
    LXB_CSS_VALUE_TEXT_TOP = 19
    LXB_CSS_VALUE__LENGTH = 20
    LXB_CSS_VALUE__PERCENTAGE = 21
    LXB_CSS_VALUE_SUB = 22
    LXB_CSS_VALUE_SUPER = 23
    LXB_CSS_VALUE_TOP = 24
    LXB_CSS_VALUE_BOTTOM = 25
    LXB_CSS_VALUE_FIRST = 26
    LXB_CSS_VALUE_LAST = 27
    LXB_CSS_VALUE_THIN = 28
    LXB_CSS_VALUE_MEDIUM = 29
    LXB_CSS_VALUE_THICK = 30
    LXB_CSS_VALUE_NONE = 31
    LXB_CSS_VALUE_HIDDEN = 32
    LXB_CSS_VALUE_DOTTED = 33
    LXB_CSS_VALUE_DASHED = 34
    LXB_CSS_VALUE_SOLID = 35
    LXB_CSS_VALUE_DOUBLE = 36
    LXB_CSS_VALUE_GROOVE = 37
    LXB_CSS_VALUE_RIDGE = 38
    LXB_CSS_VALUE_INSET = 39
    LXB_CSS_VALUE_OUTSET = 40
    LXB_CSS_VALUE_CONTENT_BOX = 41
    LXB_CSS_VALUE_BORDER_BOX = 42
    LXB_CSS_VALUE_INLINE_START = 43
    LXB_CSS_VALUE_INLINE_END = 44
    LXB_CSS_VALUE_BLOCK_START = 45
    LXB_CSS_VALUE_BLOCK_END = 46
    LXB_CSS_VALUE_LEFT = 47
    LXB_CSS_VALUE_RIGHT = 48
    LXB_CSS_VALUE_CURRENTCOLOR = 49
    LXB_CSS_VALUE_TRANSPARENT = 50
    LXB_CSS_VALUE_HEX = 51
    LXB_CSS_VALUE_ALICEBLUE = 52
    LXB_CSS_VALUE_ANTIQUEWHITE = 53
    LXB_CSS_VALUE_AQUA = 54
    LXB_CSS_VALUE_AQUAMARINE = 55
    LXB_CSS_VALUE_AZURE = 56
    LXB_CSS_VALUE_BEIGE = 57
    LXB_CSS_VALUE_BISQUE = 58
    LXB_CSS_VALUE_BLACK = 59
    LXB_CSS_VALUE_BLANCHEDALMOND = 60
    LXB_CSS_VALUE_BLUE = 61
    LXB_CSS_VALUE_BLUEVIOLET = 62
    LXB_CSS_VALUE_BROWN = 63
    LXB_CSS_VALUE_BURLYWOOD = 64
    LXB_CSS_VALUE_CADETBLUE = 65
    LXB_CSS_VALUE_CHARTREUSE = 66
    LXB_CSS_VALUE_CHOCOLATE = 67
    LXB_CSS_VALUE_CORAL = 68
    LXB_CSS_VALUE_CORNFLOWERBLUE = 69
    LXB_CSS_VALUE_CORNSILK = 70
    LXB_CSS_VALUE_CRIMSON = 71
    LXB_CSS_VALUE_CYAN = 72
    LXB_CSS_VALUE_DARKBLUE = 73
    LXB_CSS_VALUE_DARKCYAN = 74
    LXB_CSS_VALUE_DARKGOLDENROD = 75
    LXB_CSS_VALUE_DARKGRAY = 76
    LXB_CSS_VALUE_DARKGREEN = 77
    LXB_CSS_VALUE_DARKGREY = 78
    LXB_CSS_VALUE_DARKKHAKI = 79
    LXB_CSS_VALUE_DARKMAGENTA = 80
    LXB_CSS_VALUE_DARKOLIVEGREEN = 81
    LXB_CSS_VALUE_DARKORANGE = 82
    LXB_CSS_VALUE_DARKORCHID = 83
    LXB_CSS_VALUE_DARKRED = 84
    LXB_CSS_VALUE_DARKSALMON = 85
    LXB_CSS_VALUE_DARKSEAGREEN = 86
    LXB_CSS_VALUE_DARKSLATEBLUE = 87
    LXB_CSS_VALUE_DARKSLATEGRAY = 88
    LXB_CSS_VALUE_DARKSLATEGREY = 89
    LXB_CSS_VALUE_DARKTURQUOISE = 90
    LXB_CSS_VALUE_DARKVIOLET = 91
    LXB_CSS_VALUE_DEEPPINK = 92
    LXB_CSS_VALUE_DEEPSKYBLUE = 93
    LXB_CSS_VALUE_DIMGRAY = 94
    LXB_CSS_VALUE_DIMGREY = 95
    LXB_CSS_VALUE_DODGERBLUE = 96
    LXB_CSS_VALUE_FIREBRICK = 97
    LXB_CSS_VALUE_FLORALWHITE = 98
    LXB_CSS_VALUE_FORESTGREEN = 99
    LXB_CSS_VALUE_FUCHSIA = 100
    LXB_CSS_VALUE_GAINSBORO = 101
    LXB_CSS_VALUE_GHOSTWHITE = 102
    LXB_CSS_VALUE_GOLD = 103
    LXB_CSS_VALUE_GOLDENROD = 104
    LXB_CSS_VALUE_GRAY = 105
    LXB_CSS_VALUE_GREEN = 106
    LXB_CSS_VALUE_GREENYELLOW = 107
    LXB_CSS_VALUE_GREY = 108
    LXB_CSS_VALUE_HONEYDEW = 109
    LXB_CSS_VALUE_HOTPINK = 110
    LXB_CSS_VALUE_INDIANRED = 111
    LXB_CSS_VALUE_INDIGO = 112
    LXB_CSS_VALUE_IVORY = 113
    LXB_CSS_VALUE_KHAKI = 114
    LXB_CSS_VALUE_LAVENDER = 115
    LXB_CSS_VALUE_LAVENDERBLUSH = 116
    LXB_CSS_VALUE_LAWNGREEN = 117
    LXB_CSS_VALUE_LEMONCHIFFON = 118
    LXB_CSS_VALUE_LIGHTBLUE = 119
    LXB_CSS_VALUE_LIGHTCORAL = 120
    LXB_CSS_VALUE_LIGHTCYAN = 121
    LXB_CSS_VALUE_LIGHTGOLDENRODYELLOW = 122
    LXB_CSS_VALUE_LIGHTGRAY = 123
    LXB_CSS_VALUE_LIGHTGREEN = 124
    LXB_CSS_VALUE_LIGHTGREY = 125
    LXB_CSS_VALUE_LIGHTPINK = 126
    LXB_CSS_VALUE_LIGHTSALMON = 127
    LXB_CSS_VALUE_LIGHTSEAGREEN = 128
    LXB_CSS_VALUE_LIGHTSKYBLUE = 129
    LXB_CSS_VALUE_LIGHTSLATEGRAY = 130
    LXB_CSS_VALUE_LIGHTSLATEGREY = 131
    LXB_CSS_VALUE_LIGHTSTEELBLUE = 132
    LXB_CSS_VALUE_LIGHTYELLOW = 133
    LXB_CSS_VALUE_LIME = 134
    LXB_CSS_VALUE_LIMEGREEN = 135
    LXB_CSS_VALUE_LINEN = 136
    LXB_CSS_VALUE_MAGENTA = 137
    LXB_CSS_VALUE_MAROON = 138
    LXB_CSS_VALUE_MEDIUMAQUAMARINE = 139
    LXB_CSS_VALUE_MEDIUMBLUE = 140
    LXB_CSS_VALUE_MEDIUMORCHID = 141
    LXB_CSS_VALUE_MEDIUMPURPLE = 142
    LXB_CSS_VALUE_MEDIUMSEAGREEN = 143
    LXB_CSS_VALUE_MEDIUMSLATEBLUE = 144
    LXB_CSS_VALUE_MEDIUMSPRINGGREEN = 145
    LXB_CSS_VALUE_MEDIUMTURQUOISE = 146
    LXB_CSS_VALUE_MEDIUMVIOLETRED = 147
    LXB_CSS_VALUE_MIDNIGHTBLUE = 148
    LXB_CSS_VALUE_MINTCREAM = 149
    LXB_CSS_VALUE_MISTYROSE = 150
    LXB_CSS_VALUE_MOCCASIN = 151
    LXB_CSS_VALUE_NAVAJOWHITE = 152
    LXB_CSS_VALUE_NAVY = 153
    LXB_CSS_VALUE_OLDLACE = 154
    LXB_CSS_VALUE_OLIVE = 155
    LXB_CSS_VALUE_OLIVEDRAB = 156
    LXB_CSS_VALUE_ORANGE = 157
    LXB_CSS_VALUE_ORANGERED = 158
    LXB_CSS_VALUE_ORCHID = 159
    LXB_CSS_VALUE_PALEGOLDENROD = 160
    LXB_CSS_VALUE_PALEGREEN = 161
    LXB_CSS_VALUE_PALETURQUOISE = 162
    LXB_CSS_VALUE_PALEVIOLETRED = 163
    LXB_CSS_VALUE_PAPAYAWHIP = 164
    LXB_CSS_VALUE_PEACHPUFF = 165
    LXB_CSS_VALUE_PERU = 166
    LXB_CSS_VALUE_PINK = 167
    LXB_CSS_VALUE_PLUM = 168
    LXB_CSS_VALUE_POWDERBLUE = 169
    LXB_CSS_VALUE_PURPLE = 170
    LXB_CSS_VALUE_REBECCAPURPLE = 171
    LXB_CSS_VALUE_RED = 172
    LXB_CSS_VALUE_ROSYBROWN = 173
    LXB_CSS_VALUE_ROYALBLUE = 174
    LXB_CSS_VALUE_SADDLEBROWN = 175
    LXB_CSS_VALUE_SALMON = 176
    LXB_CSS_VALUE_SANDYBROWN = 177
    LXB_CSS_VALUE_SEAGREEN = 178
    LXB_CSS_VALUE_SEASHELL = 179
    LXB_CSS_VALUE_SIENNA = 180
    LXB_CSS_VALUE_SILVER = 181
    LXB_CSS_VALUE_SKYBLUE = 182
    LXB_CSS_VALUE_SLATEBLUE = 183
    LXB_CSS_VALUE_SLATEGRAY = 184
    LXB_CSS_VALUE_SLATEGREY = 185
    LXB_CSS_VALUE_SNOW = 186
    LXB_CSS_VALUE_SPRINGGREEN = 187
    LXB_CSS_VALUE_STEELBLUE = 188
    LXB_CSS_VALUE_TAN = 189
    LXB_CSS_VALUE_TEAL = 190
    LXB_CSS_VALUE_THISTLE = 191
    LXB_CSS_VALUE_TOMATO = 192
    LXB_CSS_VALUE_TURQUOISE = 193
    LXB_CSS_VALUE_VIOLET = 194
    LXB_CSS_VALUE_WHEAT = 195
    LXB_CSS_VALUE_WHITE = 196
    LXB_CSS_VALUE_WHITESMOKE = 197
    LXB_CSS_VALUE_YELLOW = 198
    LXB_CSS_VALUE_YELLOWGREEN = 199
    LXB_CSS_VALUE_CANVAS = 200
    LXB_CSS_VALUE_CANVASTEXT = 201
    LXB_CSS_VALUE_LINKTEXT = 202
    LXB_CSS_VALUE_VISITEDTEXT = 203
    LXB_CSS_VALUE_ACTIVETEXT = 204
    LXB_CSS_VALUE_BUTTONFACE = 205
    LXB_CSS_VALUE_BUTTONTEXT = 206
    LXB_CSS_VALUE_BUTTONBORDER = 207
    LXB_CSS_VALUE_FIELD = 208
    LXB_CSS_VALUE_FIELDTEXT = 209
    LXB_CSS_VALUE_HIGHLIGHT = 210
    LXB_CSS_VALUE_HIGHLIGHTTEXT = 211
    LXB_CSS_VALUE_SELECTEDITEM = 212
    LXB_CSS_VALUE_SELECTEDITEMTEXT = 213
    LXB_CSS_VALUE_MARK = 214
    LXB_CSS_VALUE_MARKTEXT = 215
    LXB_CSS_VALUE_GRAYTEXT = 216
    LXB_CSS_VALUE_ACCENTCOLOR = 217
    LXB_CSS_VALUE_ACCENTCOLORTEXT = 218
    LXB_CSS_VALUE_RGB = 219
    LXB_CSS_VALUE_RGBA = 220
    LXB_CSS_VALUE_HSL = 221
    LXB_CSS_VALUE_HSLA = 222
    LXB_CSS_VALUE_HWB = 223
    LXB_CSS_VALUE_LAB = 224
    LXB_CSS_VALUE_LCH = 225
    LXB_CSS_VALUE_OKLAB = 226
    LXB_CSS_VALUE_OKLCH = 227
    LXB_CSS_VALUE_COLOR = 228
    LXB_CSS_VALUE_LTR = 229
    LXB_CSS_VALUE_RTL = 230
    LXB_CSS_VALUE_BLOCK = 231
    LXB_CSS_VALUE_INLINE = 232
    LXB_CSS_VALUE_RUN_IN = 233
    LXB_CSS_VALUE_FLOW = 234
    LXB_CSS_VALUE_FLOW_ROOT = 235
    LXB_CSS_VALUE_TABLE = 236
    LXB_CSS_VALUE_FLEX = 237
    LXB_CSS_VALUE_GRID = 238
    LXB_CSS_VALUE_RUBY = 239
    LXB_CSS_VALUE_LIST_ITEM = 240
    LXB_CSS_VALUE_TABLE_ROW_GROUP = 241
    LXB_CSS_VALUE_TABLE_HEADER_GROUP = 242
    LXB_CSS_VALUE_TABLE_FOOTER_GROUP = 243
    LXB_CSS_VALUE_TABLE_ROW = 244
    LXB_CSS_VALUE_TABLE_CELL = 245
    LXB_CSS_VALUE_TABLE_COLUMN_GROUP = 246
    LXB_CSS_VALUE_TABLE_COLUMN = 247
    LXB_CSS_VALUE_TABLE_CAPTION = 248
    LXB_CSS_VALUE_RUBY_BASE = 249
    LXB_CSS_VALUE_RUBY_TEXT = 250
    LXB_CSS_VALUE_RUBY_BASE_CONTAINER = 251
    LXB_CSS_VALUE_RUBY_TEXT_CONTAINER = 252
    LXB_CSS_VALUE_CONTENTS = 253
    LXB_CSS_VALUE_INLINE_BLOCK = 254
    LXB_CSS_VALUE_INLINE_TABLE = 255
    LXB_CSS_VALUE_INLINE_FLEX = 256
    LXB_CSS_VALUE_INLINE_GRID = 257
    LXB_CSS_VALUE_HANGING = 258
    LXB_CSS_VALUE_CONTENT = 259
    LXB_CSS_VALUE_ROW = 260
    LXB_CSS_VALUE_ROW_REVERSE = 261
    LXB_CSS_VALUE_COLUMN = 262
    LXB_CSS_VALUE_COLUMN_REVERSE = 263
    LXB_CSS_VALUE__NUMBER = 264
    LXB_CSS_VALUE_NOWRAP = 265
    LXB_CSS_VALUE_WRAP = 266
    LXB_CSS_VALUE_WRAP_REVERSE = 267
    LXB_CSS_VALUE_SNAP_BLOCK = 268
    LXB_CSS_VALUE_START = 269
    LXB_CSS_VALUE_END = 270
    LXB_CSS_VALUE_NEAR = 271
    LXB_CSS_VALUE_SNAP_INLINE = 272
    LXB_CSS_VALUE__INTEGER = 273
    LXB_CSS_VALUE_REGION = 274
    LXB_CSS_VALUE_PAGE = 275
    LXB_CSS_VALUE_SERIF = 276
    LXB_CSS_VALUE_SANS_SERIF = 277
    LXB_CSS_VALUE_CURSIVE = 278
    LXB_CSS_VALUE_FANTASY = 279
    LXB_CSS_VALUE_MONOSPACE = 280
    LXB_CSS_VALUE_SYSTEM_UI = 281
    LXB_CSS_VALUE_EMOJI = 282
    LXB_CSS_VALUE_MATH = 283
    LXB_CSS_VALUE_FANGSONG = 284
    LXB_CSS_VALUE_UI_SERIF = 285
    LXB_CSS_VALUE_UI_SANS_SERIF = 286
    LXB_CSS_VALUE_UI_MONOSPACE = 287
    LXB_CSS_VALUE_UI_ROUNDED = 288
    LXB_CSS_VALUE_XX_SMALL = 289
    LXB_CSS_VALUE_X_SMALL = 290
    LXB_CSS_VALUE_SMALL = 291
    LXB_CSS_VALUE_LARGE = 292
    LXB_CSS_VALUE_X_LARGE = 293
    LXB_CSS_VALUE_XX_LARGE = 294
    LXB_CSS_VALUE_XXX_LARGE = 295
    LXB_CSS_VALUE_LARGER = 296
    LXB_CSS_VALUE_SMALLER = 297
    LXB_CSS_VALUE_NORMAL = 298
    LXB_CSS_VALUE_ULTRA_CONDENSED = 299
    LXB_CSS_VALUE_EXTRA_CONDENSED = 300
    LXB_CSS_VALUE_CONDENSED = 301
    LXB_CSS_VALUE_SEMI_CONDENSED = 302
    LXB_CSS_VALUE_SEMI_EXPANDED = 303
    LXB_CSS_VALUE_EXPANDED = 304
    LXB_CSS_VALUE_EXTRA_EXPANDED = 305
    LXB_CSS_VALUE_ULTRA_EXPANDED = 306
    LXB_CSS_VALUE_ITALIC = 307
    LXB_CSS_VALUE_OBLIQUE = 308
    LXB_CSS_VALUE_BOLD = 309
    LXB_CSS_VALUE_BOLDER = 310
    LXB_CSS_VALUE_LIGHTER = 311
    LXB_CSS_VALUE_FORCE_END = 312
    LXB_CSS_VALUE_ALLOW_END = 313
    LXB_CSS_VALUE_MIN_CONTENT = 314
    LXB_CSS_VALUE_MAX_CONTENT = 315
    LXB_CSS_VALUE__ANGLE = 316
    LXB_CSS_VALUE_MANUAL = 317
    LXB_CSS_VALUE_LOOSE = 318
    LXB_CSS_VALUE_STRICT = 319
    LXB_CSS_VALUE_ANYWHERE = 320
    LXB_CSS_VALUE_VISIBLE = 321
    LXB_CSS_VALUE_CLIP = 322
    LXB_CSS_VALUE_SCROLL = 323
    LXB_CSS_VALUE_BREAK_WORD = 324
    LXB_CSS_VALUE_STATIC = 325
    LXB_CSS_VALUE_RELATIVE = 326
    LXB_CSS_VALUE_ABSOLUTE = 327
    LXB_CSS_VALUE_STICKY = 328
    LXB_CSS_VALUE_FIXED = 329
    LXB_CSS_VALUE_JUSTIFY = 330
    LXB_CSS_VALUE_MATCH_PARENT = 331
    LXB_CSS_VALUE_JUSTIFY_ALL = 332
    LXB_CSS_VALUE_ALL = 333
    LXB_CSS_VALUE_DIGITS = 334
    LXB_CSS_VALUE_UNDERLINE = 335
    LXB_CSS_VALUE_OVERLINE = 336
    LXB_CSS_VALUE_LINE_THROUGH = 337
    LXB_CSS_VALUE_BLINK = 338
    LXB_CSS_VALUE_WAVY = 339
    LXB_CSS_VALUE_EACH_LINE = 340
    LXB_CSS_VALUE_INTER_WORD = 341
    LXB_CSS_VALUE_INTER_CHARACTER = 342
    LXB_CSS_VALUE_MIXED = 343
    LXB_CSS_VALUE_UPRIGHT = 344
    LXB_CSS_VALUE_SIDEWAYS = 345
    LXB_CSS_VALUE_ELLIPSIS = 346
    LXB_CSS_VALUE_CAPITALIZE = 347
    LXB_CSS_VALUE_UPPERCASE = 348
    LXB_CSS_VALUE_LOWERCASE = 349
    LXB_CSS_VALUE_FULL_WIDTH = 350
    LXB_CSS_VALUE_FULL_SIZE_KANA = 351
    LXB_CSS_VALUE_EMBED = 352
    LXB_CSS_VALUE_ISOLATE = 353
    LXB_CSS_VALUE_BIDI_OVERRIDE = 354
    LXB_CSS_VALUE_ISOLATE_OVERRIDE = 355
    LXB_CSS_VALUE_PLAINTEXT = 356
    LXB_CSS_VALUE_COLLAPSE = 357
    LXB_CSS_VALUE_PRE = 358
    LXB_CSS_VALUE_PRE_WRAP = 359
    LXB_CSS_VALUE_BREAK_SPACES = 360
    LXB_CSS_VALUE_PRE_LINE = 361
    LXB_CSS_VALUE_KEEP_ALL = 362
    LXB_CSS_VALUE_BREAK_ALL = 363
    LXB_CSS_VALUE_BOTH = 364
    LXB_CSS_VALUE_MINIMUM = 365
    LXB_CSS_VALUE_MAXIMUM = 366
    LXB_CSS_VALUE_CLEAR = 367
    LXB_CSS_VALUE_HORIZONTAL_TB = 368
    LXB_CSS_VALUE_VERTICAL_RL = 369
    LXB_CSS_VALUE_VERTICAL_LR = 370
    LXB_CSS_VALUE_SIDEWAYS_RL = 371
    LXB_CSS_VALUE_SIDEWAYS_LR = 372
    LXB_CSS_VALUE__LAST_ENTRY = 373
end

const lxb_css_value_type_t = Cuint

@cenum __JL_Ctag_51::UInt32 begin
    LXB_CSS_AT_RULE__UNDEF = 0
    LXB_CSS_AT_RULE__CUSTOM = 1
    LXB_CSS_AT_RULE_MEDIA = 2
    LXB_CSS_AT_RULE_NAMESPACE = 3
    LXB_CSS_AT_RULE__LAST_ENTRY = 4
end

const lxb_css_at_rule_type_t = Csize_t

struct lxb_css_at_rule__undef_t
    type::lxb_css_at_rule_type_t
    prelude::lexbor_str_t
    block::lexbor_str_t
end

struct lxb_css_at_rule__custom_t
    name::lexbor_str_t
    prelude::lexbor_str_t
    block::lexbor_str_t
end

struct lxb_css_at_rule_media_t
    reserved::Csize_t
end

struct lxb_css_at_rule_namespace_t
    reserved::Csize_t
end

@cenum lxb_css_unit_t::UInt32 begin
    LXB_CSS_UNIT__UNDEF = 0
    LXB_CSS_UNIT__LAST_ENTRY = 34
end

@cenum lxb_css_unit_absolute_t::UInt32 begin
    LXB_CSS_UNIT_ABSOLUTE__BEGIN = 1
    LXB_CSS_UNIT_Q = 1
    LXB_CSS_UNIT_CM = 2
    LXB_CSS_UNIT_IN = 3
    LXB_CSS_UNIT_MM = 4
    LXB_CSS_UNIT_PC = 5
    LXB_CSS_UNIT_PT = 6
    LXB_CSS_UNIT_PX = 7
    LXB_CSS_UNIT_ABSOLUTE__LAST_ENTRY = 8
end

@cenum lxb_css_unit_relative_t::UInt32 begin
    LXB_CSS_UNIT_RELATIVE__BEGIN = 8
    LXB_CSS_UNIT_CAP = 8
    LXB_CSS_UNIT_CH = 9
    LXB_CSS_UNIT_EM = 10
    LXB_CSS_UNIT_EX = 11
    LXB_CSS_UNIT_IC = 12
    LXB_CSS_UNIT_LH = 13
    LXB_CSS_UNIT_REM = 14
    LXB_CSS_UNIT_RLH = 15
    LXB_CSS_UNIT_VB = 16
    LXB_CSS_UNIT_VH = 17
    LXB_CSS_UNIT_VI = 18
    LXB_CSS_UNIT_VMAX = 19
    LXB_CSS_UNIT_VMIN = 20
    LXB_CSS_UNIT_VW = 21
    LXB_CSS_UNIT_RELATIVE__LAST_ENTRY = 22
end

@cenum lxb_css_unit_angel_t::UInt32 begin
    LXB_CSS_UNIT_ANGEL__BEGIN = 22
    LXB_CSS_UNIT_DEG = 22
    LXB_CSS_UNIT_GRAD = 23
    LXB_CSS_UNIT_RAD = 24
    LXB_CSS_UNIT_TURN = 25
    LXB_CSS_UNIT_ANGEL__LAST_ENTRY = 26
end

@cenum lxb_css_unit_frequency_t::UInt32 begin
    LXB_CSS_UNIT_FREQUENCY__BEGIN = 26
    LXB_CSS_UNIT_HZ = 26
    LXB_CSS_UNIT_KHZ = 27
    LXB_CSS_UNIT_FREQUENCY__LAST_ENTRY = 28
end

@cenum lxb_css_unit_resolution_t::UInt32 begin
    LXB_CSS_UNIT_RESOLUTION__BEGIN = 28
    LXB_CSS_UNIT_DPCM = 28
    LXB_CSS_UNIT_DPI = 29
    LXB_CSS_UNIT_DPPX = 30
    LXB_CSS_UNIT_X = 31
    LXB_CSS_UNIT_RESOLUTION__LAST_ENTRY = 32
end

@cenum lxb_css_unit_duration_t::UInt32 begin
    LXB_CSS_UNIT_DURATION__BEGIN = 32
    LXB_CSS_UNIT_MS = 32
    LXB_CSS_UNIT_S = 33
    LXB_CSS_UNIT_DURATION__LAST_ENTRY = 34
end

struct lxb_css_value_number_t
    num::Cdouble
    is_float::Bool
end

struct lxb_css_value_integer_t
    num::Clong
end

const lxb_css_value_percentage_t = lxb_css_value_number_t

struct lxb_css_value_length_t
    num::Cdouble
    is_float::Bool
    unit::lxb_css_unit_t
end

struct __JL_Ctag_268
    data::NTuple{16,UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_268}, f::Symbol)
    f === :length && return Ptr{lxb_css_value_length_t}(x + 0)
    f === :percentage && return Ptr{lxb_css_value_percentage_t}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_268, f::Symbol)
    r = Ref{__JL_Ctag_268}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_268}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_268}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct lxb_css_value_length_percentage_t
    data::NTuple{24,UInt8}
end

function Base.getproperty(x::Ptr{lxb_css_value_length_percentage_t}, f::Symbol)
    f === :type && return Ptr{lxb_css_value_type_t}(x + 0)
    f === :u && return Ptr{__JL_Ctag_268}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::lxb_css_value_length_percentage_t, f::Symbol)
    r = Ref{lxb_css_value_length_percentage_t}(x)
    ptr = Base.unsafe_convert(Ptr{lxb_css_value_length_percentage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{lxb_css_value_length_percentage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct __JL_Ctag_267
    data::NTuple{16,UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_267}, f::Symbol)
    f === :number && return Ptr{lxb_css_value_number_t}(x + 0)
    f === :length && return Ptr{lxb_css_value_length_t}(x + 0)
    f === :percentage && return Ptr{lxb_css_value_percentage_t}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_267, f::Symbol)
    r = Ref{__JL_Ctag_267}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_267}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_267}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct lxb_css_value_number_length_percentage_t
    data::NTuple{24,UInt8}
end

function Base.getproperty(x::Ptr{lxb_css_value_number_length_percentage_t}, f::Symbol)
    f === :type && return Ptr{lxb_css_value_type_t}(x + 0)
    f === :u && return Ptr{__JL_Ctag_267}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::lxb_css_value_number_length_percentage_t, f::Symbol)
    r = Ref{lxb_css_value_number_length_percentage_t}(x)
    ptr = Base.unsafe_convert(Ptr{lxb_css_value_number_length_percentage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{lxb_css_value_number_length_percentage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct __JL_Ctag_277
    data::NTuple{16,UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_277}, f::Symbol)
    f === :number && return Ptr{lxb_css_value_number_t}(x + 0)
    f === :length && return Ptr{lxb_css_value_length_t}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_277, f::Symbol)
    r = Ref{__JL_Ctag_277}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_277}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_277}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct lxb_css_value_number_length_t
    data::NTuple{24,UInt8}
end

function Base.getproperty(x::Ptr{lxb_css_value_number_length_t}, f::Symbol)
    f === :type && return Ptr{lxb_css_value_type_t}(x + 0)
    f === :u && return Ptr{__JL_Ctag_277}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::lxb_css_value_number_length_t, f::Symbol)
    r = Ref{lxb_css_value_number_length_t}(x)
    ptr = Base.unsafe_convert(Ptr{lxb_css_value_number_length_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{lxb_css_value_number_length_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct __JL_Ctag_274
    data::NTuple{16,UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_274}, f::Symbol)
    f === :number && return Ptr{lxb_css_value_number_t}(x + 0)
    f === :percentage && return Ptr{lxb_css_value_percentage_t}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_274, f::Symbol)
    r = Ref{__JL_Ctag_274}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_274}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_274}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct lxb_css_value_number_percentage_t
    data::NTuple{24,UInt8}
end

function Base.getproperty(x::Ptr{lxb_css_value_number_percentage_t}, f::Symbol)
    f === :type && return Ptr{lxb_css_value_type_t}(x + 0)
    f === :u && return Ptr{__JL_Ctag_274}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::lxb_css_value_number_percentage_t, f::Symbol)
    r = Ref{lxb_css_value_number_percentage_t}(x)
    ptr = Base.unsafe_convert(Ptr{lxb_css_value_number_percentage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{lxb_css_value_number_percentage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct lxb_css_value_number_type_t
    type::lxb_css_value_type_t
    number::lxb_css_value_number_t
end

struct lxb_css_value_integer_type_t
    type::lxb_css_value_type_t
    integer::lxb_css_value_integer_t
end

struct lxb_css_value_percentage_type_t
    type::lxb_css_value_type_t
    percentage::lxb_css_value_percentage_t
end

struct lxb_css_value_length_type_t
    type::lxb_css_value_type_t
    length::lxb_css_value_length_t
end

struct lxb_css_value_length_percentage_type_t
    type::lxb_css_value_type_t
    length::lxb_css_value_length_percentage_t
end

struct lxb_css_value_angle_t
    num::Cdouble
    is_float::Bool
    unit::lxb_css_unit_angel_t
end

struct lxb_css_value_angle_type_t
    type::lxb_css_value_type_t
    angle::lxb_css_value_angle_t
end

struct __JL_Ctag_273
    data::NTuple{16,UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_273}, f::Symbol)
    f === :number && return Ptr{lxb_css_value_number_t}(x + 0)
    f === :angle && return Ptr{lxb_css_value_angle_t}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_273, f::Symbol)
    r = Ref{__JL_Ctag_273}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_273}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_273}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct lxb_css_value_hue_t
    data::NTuple{24,UInt8}
end

function Base.getproperty(x::Ptr{lxb_css_value_hue_t}, f::Symbol)
    f === :type && return Ptr{lxb_css_value_type_t}(x + 0)
    f === :u && return Ptr{__JL_Ctag_273}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::lxb_css_value_hue_t, f::Symbol)
    r = Ref{lxb_css_value_hue_t}(x)
    ptr = Base.unsafe_convert(Ptr{lxb_css_value_hue_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{lxb_css_value_hue_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct lxb_css_value_color_hex_rgba_t
    r::UInt8
    g::UInt8
    b::UInt8
    a::UInt8
end

@cenum lxb_css_value_color_hex_type_t::UInt32 begin
    LXB_CSS_PROPERTY_COLOR_HEX_TYPE_3 = 0
    LXB_CSS_PROPERTY_COLOR_HEX_TYPE_4 = 1
    LXB_CSS_PROPERTY_COLOR_HEX_TYPE_6 = 2
    LXB_CSS_PROPERTY_COLOR_HEX_TYPE_8 = 3
end

struct lxb_css_value_color_hex_t
    rgba::lxb_css_value_color_hex_rgba_t
    type::lxb_css_value_color_hex_type_t
end

struct lxb_css_value_color_rgba_t
    r::lxb_css_value_number_percentage_t
    g::lxb_css_value_number_percentage_t
    b::lxb_css_value_number_percentage_t
    a::lxb_css_value_number_percentage_t
    old::Bool
end

struct lxb_css_value_color_hsla_t
    h::lxb_css_value_hue_t
    s::lxb_css_value_percentage_type_t
    l::lxb_css_value_percentage_type_t
    a::lxb_css_value_number_percentage_t
    old::Bool
end

struct lxb_css_value_color_lab_t
    l::lxb_css_value_number_percentage_t
    a::lxb_css_value_number_percentage_t
    b::lxb_css_value_number_percentage_t
    alpha::lxb_css_value_number_percentage_t
end

struct lxb_css_value_color_lch_t
    l::lxb_css_value_number_percentage_t
    c::lxb_css_value_number_percentage_t
    h::lxb_css_value_hue_t
    a::lxb_css_value_number_percentage_t
end

struct __JL_Ctag_275
    data::NTuple{104,UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_275}, f::Symbol)
    f === :hex && return Ptr{lxb_css_value_color_hex_t}(x + 0)
    f === :rgb && return Ptr{lxb_css_value_color_rgba_t}(x + 0)
    f === :hsl && return Ptr{lxb_css_value_color_hsla_t}(x + 0)
    f === :hwb && return Ptr{lxb_css_value_color_hsla_t}(x + 0)
    f === :lab && return Ptr{lxb_css_value_color_lab_t}(x + 0)
    f === :lch && return Ptr{lxb_css_value_color_lch_t}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_275, f::Symbol)
    r = Ref{__JL_Ctag_275}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_275}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_275}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct lxb_css_value_color_t
    data::NTuple{112,UInt8}
end

function Base.getproperty(x::Ptr{lxb_css_value_color_t}, f::Symbol)
    f === :type && return Ptr{lxb_css_value_type_t}(x + 0)
    f === :u && return Ptr{__JL_Ctag_275}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::lxb_css_value_color_t, f::Symbol)
    r = Ref{lxb_css_value_color_t}(x)
    ptr = Base.unsafe_convert(Ptr{lxb_css_value_color_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{lxb_css_value_color_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum __JL_Ctag_86::UInt32 begin
    LXB_CSS_PROPERTY__UNDEF = 0
    LXB_CSS_PROPERTY__CUSTOM = 1
    LXB_CSS_PROPERTY_ALIGN_CONTENT = 2
    LXB_CSS_PROPERTY_ALIGN_ITEMS = 3
    LXB_CSS_PROPERTY_ALIGN_SELF = 4
    LXB_CSS_PROPERTY_ALIGNMENT_BASELINE = 5
    LXB_CSS_PROPERTY_BACKGROUND_COLOR = 6
    LXB_CSS_PROPERTY_BASELINE_SHIFT = 7
    LXB_CSS_PROPERTY_BASELINE_SOURCE = 8
    LXB_CSS_PROPERTY_BORDER = 9
    LXB_CSS_PROPERTY_BORDER_BOTTOM = 10
    LXB_CSS_PROPERTY_BORDER_BOTTOM_COLOR = 11
    LXB_CSS_PROPERTY_BORDER_LEFT = 12
    LXB_CSS_PROPERTY_BORDER_LEFT_COLOR = 13
    LXB_CSS_PROPERTY_BORDER_RIGHT = 14
    LXB_CSS_PROPERTY_BORDER_RIGHT_COLOR = 15
    LXB_CSS_PROPERTY_BORDER_TOP = 16
    LXB_CSS_PROPERTY_BORDER_TOP_COLOR = 17
    LXB_CSS_PROPERTY_BOTTOM = 18
    LXB_CSS_PROPERTY_BOX_SIZING = 19
    LXB_CSS_PROPERTY_CLEAR = 20
    LXB_CSS_PROPERTY_COLOR = 21
    LXB_CSS_PROPERTY_DIRECTION = 22
    LXB_CSS_PROPERTY_DISPLAY = 23
    LXB_CSS_PROPERTY_DOMINANT_BASELINE = 24
    LXB_CSS_PROPERTY_FLEX = 25
    LXB_CSS_PROPERTY_FLEX_BASIS = 26
    LXB_CSS_PROPERTY_FLEX_DIRECTION = 27
    LXB_CSS_PROPERTY_FLEX_FLOW = 28
    LXB_CSS_PROPERTY_FLEX_GROW = 29
    LXB_CSS_PROPERTY_FLEX_SHRINK = 30
    LXB_CSS_PROPERTY_FLEX_WRAP = 31
    LXB_CSS_PROPERTY_FLOAT = 32
    LXB_CSS_PROPERTY_FLOAT_DEFER = 33
    LXB_CSS_PROPERTY_FLOAT_OFFSET = 34
    LXB_CSS_PROPERTY_FLOAT_REFERENCE = 35
    LXB_CSS_PROPERTY_FONT_FAMILY = 36
    LXB_CSS_PROPERTY_FONT_SIZE = 37
    LXB_CSS_PROPERTY_FONT_STRETCH = 38
    LXB_CSS_PROPERTY_FONT_STYLE = 39
    LXB_CSS_PROPERTY_FONT_WEIGHT = 40
    LXB_CSS_PROPERTY_HANGING_PUNCTUATION = 41
    LXB_CSS_PROPERTY_HEIGHT = 42
    LXB_CSS_PROPERTY_HYPHENS = 43
    LXB_CSS_PROPERTY_INSET_BLOCK_END = 44
    LXB_CSS_PROPERTY_INSET_BLOCK_START = 45
    LXB_CSS_PROPERTY_INSET_INLINE_END = 46
    LXB_CSS_PROPERTY_INSET_INLINE_START = 47
    LXB_CSS_PROPERTY_JUSTIFY_CONTENT = 48
    LXB_CSS_PROPERTY_LEFT = 49
    LXB_CSS_PROPERTY_LETTER_SPACING = 50
    LXB_CSS_PROPERTY_LINE_BREAK = 51
    LXB_CSS_PROPERTY_LINE_HEIGHT = 52
    LXB_CSS_PROPERTY_MARGIN = 53
    LXB_CSS_PROPERTY_MARGIN_BOTTOM = 54
    LXB_CSS_PROPERTY_MARGIN_LEFT = 55
    LXB_CSS_PROPERTY_MARGIN_RIGHT = 56
    LXB_CSS_PROPERTY_MARGIN_TOP = 57
    LXB_CSS_PROPERTY_MAX_HEIGHT = 58
    LXB_CSS_PROPERTY_MAX_WIDTH = 59
    LXB_CSS_PROPERTY_MIN_HEIGHT = 60
    LXB_CSS_PROPERTY_MIN_WIDTH = 61
    LXB_CSS_PROPERTY_OPACITY = 62
    LXB_CSS_PROPERTY_ORDER = 63
    LXB_CSS_PROPERTY_OVERFLOW_BLOCK = 64
    LXB_CSS_PROPERTY_OVERFLOW_INLINE = 65
    LXB_CSS_PROPERTY_OVERFLOW_WRAP = 66
    LXB_CSS_PROPERTY_OVERFLOW_X = 67
    LXB_CSS_PROPERTY_OVERFLOW_Y = 68
    LXB_CSS_PROPERTY_PADDING = 69
    LXB_CSS_PROPERTY_PADDING_BOTTOM = 70
    LXB_CSS_PROPERTY_PADDING_LEFT = 71
    LXB_CSS_PROPERTY_PADDING_RIGHT = 72
    LXB_CSS_PROPERTY_PADDING_TOP = 73
    LXB_CSS_PROPERTY_POSITION = 74
    LXB_CSS_PROPERTY_RIGHT = 75
    LXB_CSS_PROPERTY_TAB_SIZE = 76
    LXB_CSS_PROPERTY_TEXT_ALIGN = 77
    LXB_CSS_PROPERTY_TEXT_ALIGN_ALL = 78
    LXB_CSS_PROPERTY_TEXT_ALIGN_LAST = 79
    LXB_CSS_PROPERTY_TEXT_COMBINE_UPRIGHT = 80
    LXB_CSS_PROPERTY_TEXT_DECORATION = 81
    LXB_CSS_PROPERTY_TEXT_DECORATION_COLOR = 82
    LXB_CSS_PROPERTY_TEXT_DECORATION_LINE = 83
    LXB_CSS_PROPERTY_TEXT_DECORATION_STYLE = 84
    LXB_CSS_PROPERTY_TEXT_INDENT = 85
    LXB_CSS_PROPERTY_TEXT_JUSTIFY = 86
    LXB_CSS_PROPERTY_TEXT_ORIENTATION = 87
    LXB_CSS_PROPERTY_TEXT_OVERFLOW = 88
    LXB_CSS_PROPERTY_TEXT_TRANSFORM = 89
    LXB_CSS_PROPERTY_TOP = 90
    LXB_CSS_PROPERTY_UNICODE_BIDI = 91
    LXB_CSS_PROPERTY_VERTICAL_ALIGN = 92
    LXB_CSS_PROPERTY_VISIBILITY = 93
    LXB_CSS_PROPERTY_WHITE_SPACE = 94
    LXB_CSS_PROPERTY_WIDTH = 95
    LXB_CSS_PROPERTY_WORD_BREAK = 96
    LXB_CSS_PROPERTY_WORD_SPACING = 97
    LXB_CSS_PROPERTY_WORD_WRAP = 98
    LXB_CSS_PROPERTY_WRAP_FLOW = 99
    LXB_CSS_PROPERTY_WRAP_THROUGH = 100
    LXB_CSS_PROPERTY_WRITING_MODE = 101
    LXB_CSS_PROPERTY_Z_INDEX = 102
    LXB_CSS_PROPERTY__LAST_ENTRY = 103
end

const lxb_css_property_type_t = Csize_t

@cenum __JL_Ctag_87::UInt32 begin
    LXB_CSS_ALIGN_CONTENT_FLEX_START = 5
    LXB_CSS_ALIGN_CONTENT_FLEX_END = 6
    LXB_CSS_ALIGN_CONTENT_CENTER = 7
    LXB_CSS_ALIGN_CONTENT_SPACE_BETWEEN = 8
    LXB_CSS_ALIGN_CONTENT_SPACE_AROUND = 9
    LXB_CSS_ALIGN_CONTENT_STRETCH = 10
end

const lxb_css_align_content_type_t = Cuint

@cenum __JL_Ctag_88::UInt32 begin
    LXB_CSS_ALIGN_ITEMS_FLEX_START = 5
    LXB_CSS_ALIGN_ITEMS_FLEX_END = 6
    LXB_CSS_ALIGN_ITEMS_CENTER = 7
    LXB_CSS_ALIGN_ITEMS_BASELINE = 11
    LXB_CSS_ALIGN_ITEMS_STRETCH = 10
end

const lxb_css_align_items_type_t = Cuint

@cenum __JL_Ctag_89::UInt32 begin
    LXB_CSS_ALIGN_SELF_AUTO = 12
    LXB_CSS_ALIGN_SELF_FLEX_START = 5
    LXB_CSS_ALIGN_SELF_FLEX_END = 6
    LXB_CSS_ALIGN_SELF_CENTER = 7
    LXB_CSS_ALIGN_SELF_BASELINE = 11
    LXB_CSS_ALIGN_SELF_STRETCH = 10
end

const lxb_css_align_self_type_t = Cuint

@cenum __JL_Ctag_90::UInt32 begin
    LXB_CSS_ALIGNMENT_BASELINE_BASELINE = 11
    LXB_CSS_ALIGNMENT_BASELINE_TEXT_BOTTOM = 13
    LXB_CSS_ALIGNMENT_BASELINE_ALPHABETIC = 14
    LXB_CSS_ALIGNMENT_BASELINE_IDEOGRAPHIC = 15
    LXB_CSS_ALIGNMENT_BASELINE_MIDDLE = 16
    LXB_CSS_ALIGNMENT_BASELINE_CENTRAL = 17
    LXB_CSS_ALIGNMENT_BASELINE_MATHEMATICAL = 18
    LXB_CSS_ALIGNMENT_BASELINE_TEXT_TOP = 19
end

const lxb_css_alignment_baseline_type_t = Cuint

@cenum __JL_Ctag_91::UInt32 begin
    LXB_CSS_BASELINE_SHIFT__LENGTH = 20
    LXB_CSS_BASELINE_SHIFT__PERCENTAGE = 21
    LXB_CSS_BASELINE_SHIFT_SUB = 22
    LXB_CSS_BASELINE_SHIFT_SUPER = 23
    LXB_CSS_BASELINE_SHIFT_TOP = 24
    LXB_CSS_BASELINE_SHIFT_CENTER = 7
    LXB_CSS_BASELINE_SHIFT_BOTTOM = 25
end

const lxb_css_baseline_shift_type_t = Cuint

@cenum __JL_Ctag_92::UInt32 begin
    LXB_CSS_BASELINE_SOURCE_AUTO = 12
    LXB_CSS_BASELINE_SOURCE_FIRST = 26
    LXB_CSS_BASELINE_SOURCE_LAST = 27
end

const lxb_css_baseline_source_type_t = Cuint

@cenum __JL_Ctag_93::UInt32 begin
    LXB_CSS_BORDER_THIN = 28
    LXB_CSS_BORDER_MEDIUM = 29
    LXB_CSS_BORDER_THICK = 30
    LXB_CSS_BORDER_NONE = 31
    LXB_CSS_BORDER_HIDDEN = 32
    LXB_CSS_BORDER_DOTTED = 33
    LXB_CSS_BORDER_DASHED = 34
    LXB_CSS_BORDER_SOLID = 35
    LXB_CSS_BORDER_DOUBLE = 36
    LXB_CSS_BORDER_GROOVE = 37
    LXB_CSS_BORDER_RIDGE = 38
    LXB_CSS_BORDER_INSET = 39
    LXB_CSS_BORDER_OUTSET = 40
    LXB_CSS_BORDER__LENGTH = 20
end

const lxb_css_border_type_t = Cuint

@cenum __JL_Ctag_94::UInt32 begin
    LXB_CSS_BORDER_BOTTOM_THIN = 28
    LXB_CSS_BORDER_BOTTOM_MEDIUM = 29
    LXB_CSS_BORDER_BOTTOM_THICK = 30
    LXB_CSS_BORDER_BOTTOM_NONE = 31
    LXB_CSS_BORDER_BOTTOM_HIDDEN = 32
    LXB_CSS_BORDER_BOTTOM_DOTTED = 33
    LXB_CSS_BORDER_BOTTOM_DASHED = 34
    LXB_CSS_BORDER_BOTTOM_SOLID = 35
    LXB_CSS_BORDER_BOTTOM_DOUBLE = 36
    LXB_CSS_BORDER_BOTTOM_GROOVE = 37
    LXB_CSS_BORDER_BOTTOM_RIDGE = 38
    LXB_CSS_BORDER_BOTTOM_INSET = 39
    LXB_CSS_BORDER_BOTTOM_OUTSET = 40
    LXB_CSS_BORDER_BOTTOM__LENGTH = 20
end

const lxb_css_border_bottom_type_t = Cuint

@cenum __JL_Ctag_95::UInt32 begin
    LXB_CSS_BORDER_LEFT_THIN = 28
    LXB_CSS_BORDER_LEFT_MEDIUM = 29
    LXB_CSS_BORDER_LEFT_THICK = 30
    LXB_CSS_BORDER_LEFT_NONE = 31
    LXB_CSS_BORDER_LEFT_HIDDEN = 32
    LXB_CSS_BORDER_LEFT_DOTTED = 33
    LXB_CSS_BORDER_LEFT_DASHED = 34
    LXB_CSS_BORDER_LEFT_SOLID = 35
    LXB_CSS_BORDER_LEFT_DOUBLE = 36
    LXB_CSS_BORDER_LEFT_GROOVE = 37
    LXB_CSS_BORDER_LEFT_RIDGE = 38
    LXB_CSS_BORDER_LEFT_INSET = 39
    LXB_CSS_BORDER_LEFT_OUTSET = 40
    LXB_CSS_BORDER_LEFT__LENGTH = 20
end

const lxb_css_border_left_type_t = Cuint

@cenum __JL_Ctag_96::UInt32 begin
    LXB_CSS_BORDER_RIGHT_THIN = 28
    LXB_CSS_BORDER_RIGHT_MEDIUM = 29
    LXB_CSS_BORDER_RIGHT_THICK = 30
    LXB_CSS_BORDER_RIGHT_NONE = 31
    LXB_CSS_BORDER_RIGHT_HIDDEN = 32
    LXB_CSS_BORDER_RIGHT_DOTTED = 33
    LXB_CSS_BORDER_RIGHT_DASHED = 34
    LXB_CSS_BORDER_RIGHT_SOLID = 35
    LXB_CSS_BORDER_RIGHT_DOUBLE = 36
    LXB_CSS_BORDER_RIGHT_GROOVE = 37
    LXB_CSS_BORDER_RIGHT_RIDGE = 38
    LXB_CSS_BORDER_RIGHT_INSET = 39
    LXB_CSS_BORDER_RIGHT_OUTSET = 40
    LXB_CSS_BORDER_RIGHT__LENGTH = 20
end

const lxb_css_border_right_type_t = Cuint

@cenum __JL_Ctag_97::UInt32 begin
    LXB_CSS_BORDER_TOP_THIN = 28
    LXB_CSS_BORDER_TOP_MEDIUM = 29
    LXB_CSS_BORDER_TOP_THICK = 30
    LXB_CSS_BORDER_TOP_NONE = 31
    LXB_CSS_BORDER_TOP_HIDDEN = 32
    LXB_CSS_BORDER_TOP_DOTTED = 33
    LXB_CSS_BORDER_TOP_DASHED = 34
    LXB_CSS_BORDER_TOP_SOLID = 35
    LXB_CSS_BORDER_TOP_DOUBLE = 36
    LXB_CSS_BORDER_TOP_GROOVE = 37
    LXB_CSS_BORDER_TOP_RIDGE = 38
    LXB_CSS_BORDER_TOP_INSET = 39
    LXB_CSS_BORDER_TOP_OUTSET = 40
    LXB_CSS_BORDER_TOP__LENGTH = 20
end

const lxb_css_border_top_type_t = Cuint

@cenum __JL_Ctag_98::UInt32 begin
    LXB_CSS_BOTTOM_AUTO = 12
    LXB_CSS_BOTTOM__LENGTH = 20
    LXB_CSS_BOTTOM__PERCENTAGE = 21
end

const lxb_css_bottom_type_t = Cuint

@cenum __JL_Ctag_99::UInt32 begin
    LXB_CSS_BOX_SIZING_CONTENT_BOX = 41
    LXB_CSS_BOX_SIZING_BORDER_BOX = 42
end

const lxb_css_box_sizing_type_t = Cuint

@cenum __JL_Ctag_100::UInt32 begin
    LXB_CSS_CLEAR_INLINE_START = 43
    LXB_CSS_CLEAR_INLINE_END = 44
    LXB_CSS_CLEAR_BLOCK_START = 45
    LXB_CSS_CLEAR_BLOCK_END = 46
    LXB_CSS_CLEAR_LEFT = 47
    LXB_CSS_CLEAR_RIGHT = 48
    LXB_CSS_CLEAR_TOP = 24
    LXB_CSS_CLEAR_BOTTOM = 25
    LXB_CSS_CLEAR_NONE = 31
end

const lxb_css_clear_type_t = Cuint

@cenum __JL_Ctag_101::UInt32 begin
    LXB_CSS_COLOR_CURRENTCOLOR = 49
    LXB_CSS_COLOR_TRANSPARENT = 50
    LXB_CSS_COLOR_HEX = 51
    LXB_CSS_COLOR_ALICEBLUE = 52
    LXB_CSS_COLOR_ANTIQUEWHITE = 53
    LXB_CSS_COLOR_AQUA = 54
    LXB_CSS_COLOR_AQUAMARINE = 55
    LXB_CSS_COLOR_AZURE = 56
    LXB_CSS_COLOR_BEIGE = 57
    LXB_CSS_COLOR_BISQUE = 58
    LXB_CSS_COLOR_BLACK = 59
    LXB_CSS_COLOR_BLANCHEDALMOND = 60
    LXB_CSS_COLOR_BLUE = 61
    LXB_CSS_COLOR_BLUEVIOLET = 62
    LXB_CSS_COLOR_BROWN = 63
    LXB_CSS_COLOR_BURLYWOOD = 64
    LXB_CSS_COLOR_CADETBLUE = 65
    LXB_CSS_COLOR_CHARTREUSE = 66
    LXB_CSS_COLOR_CHOCOLATE = 67
    LXB_CSS_COLOR_CORAL = 68
    LXB_CSS_COLOR_CORNFLOWERBLUE = 69
    LXB_CSS_COLOR_CORNSILK = 70
    LXB_CSS_COLOR_CRIMSON = 71
    LXB_CSS_COLOR_CYAN = 72
    LXB_CSS_COLOR_DARKBLUE = 73
    LXB_CSS_COLOR_DARKCYAN = 74
    LXB_CSS_COLOR_DARKGOLDENROD = 75
    LXB_CSS_COLOR_DARKGRAY = 76
    LXB_CSS_COLOR_DARKGREEN = 77
    LXB_CSS_COLOR_DARKGREY = 78
    LXB_CSS_COLOR_DARKKHAKI = 79
    LXB_CSS_COLOR_DARKMAGENTA = 80
    LXB_CSS_COLOR_DARKOLIVEGREEN = 81
    LXB_CSS_COLOR_DARKORANGE = 82
    LXB_CSS_COLOR_DARKORCHID = 83
    LXB_CSS_COLOR_DARKRED = 84
    LXB_CSS_COLOR_DARKSALMON = 85
    LXB_CSS_COLOR_DARKSEAGREEN = 86
    LXB_CSS_COLOR_DARKSLATEBLUE = 87
    LXB_CSS_COLOR_DARKSLATEGRAY = 88
    LXB_CSS_COLOR_DARKSLATEGREY = 89
    LXB_CSS_COLOR_DARKTURQUOISE = 90
    LXB_CSS_COLOR_DARKVIOLET = 91
    LXB_CSS_COLOR_DEEPPINK = 92
    LXB_CSS_COLOR_DEEPSKYBLUE = 93
    LXB_CSS_COLOR_DIMGRAY = 94
    LXB_CSS_COLOR_DIMGREY = 95
    LXB_CSS_COLOR_DODGERBLUE = 96
    LXB_CSS_COLOR_FIREBRICK = 97
    LXB_CSS_COLOR_FLORALWHITE = 98
    LXB_CSS_COLOR_FORESTGREEN = 99
    LXB_CSS_COLOR_FUCHSIA = 100
    LXB_CSS_COLOR_GAINSBORO = 101
    LXB_CSS_COLOR_GHOSTWHITE = 102
    LXB_CSS_COLOR_GOLD = 103
    LXB_CSS_COLOR_GOLDENROD = 104
    LXB_CSS_COLOR_GRAY = 105
    LXB_CSS_COLOR_GREEN = 106
    LXB_CSS_COLOR_GREENYELLOW = 107
    LXB_CSS_COLOR_GREY = 108
    LXB_CSS_COLOR_HONEYDEW = 109
    LXB_CSS_COLOR_HOTPINK = 110
    LXB_CSS_COLOR_INDIANRED = 111
    LXB_CSS_COLOR_INDIGO = 112
    LXB_CSS_COLOR_IVORY = 113
    LXB_CSS_COLOR_KHAKI = 114
    LXB_CSS_COLOR_LAVENDER = 115
    LXB_CSS_COLOR_LAVENDERBLUSH = 116
    LXB_CSS_COLOR_LAWNGREEN = 117
    LXB_CSS_COLOR_LEMONCHIFFON = 118
    LXB_CSS_COLOR_LIGHTBLUE = 119
    LXB_CSS_COLOR_LIGHTCORAL = 120
    LXB_CSS_COLOR_LIGHTCYAN = 121
    LXB_CSS_COLOR_LIGHTGOLDENRODYELLOW = 122
    LXB_CSS_COLOR_LIGHTGRAY = 123
    LXB_CSS_COLOR_LIGHTGREEN = 124
    LXB_CSS_COLOR_LIGHTGREY = 125
    LXB_CSS_COLOR_LIGHTPINK = 126
    LXB_CSS_COLOR_LIGHTSALMON = 127
    LXB_CSS_COLOR_LIGHTSEAGREEN = 128
    LXB_CSS_COLOR_LIGHTSKYBLUE = 129
    LXB_CSS_COLOR_LIGHTSLATEGRAY = 130
    LXB_CSS_COLOR_LIGHTSLATEGREY = 131
    LXB_CSS_COLOR_LIGHTSTEELBLUE = 132
    LXB_CSS_COLOR_LIGHTYELLOW = 133
    LXB_CSS_COLOR_LIME = 134
    LXB_CSS_COLOR_LIMEGREEN = 135
    LXB_CSS_COLOR_LINEN = 136
    LXB_CSS_COLOR_MAGENTA = 137
    LXB_CSS_COLOR_MAROON = 138
    LXB_CSS_COLOR_MEDIUMAQUAMARINE = 139
    LXB_CSS_COLOR_MEDIUMBLUE = 140
    LXB_CSS_COLOR_MEDIUMORCHID = 141
    LXB_CSS_COLOR_MEDIUMPURPLE = 142
    LXB_CSS_COLOR_MEDIUMSEAGREEN = 143
    LXB_CSS_COLOR_MEDIUMSLATEBLUE = 144
    LXB_CSS_COLOR_MEDIUMSPRINGGREEN = 145
    LXB_CSS_COLOR_MEDIUMTURQUOISE = 146
    LXB_CSS_COLOR_MEDIUMVIOLETRED = 147
    LXB_CSS_COLOR_MIDNIGHTBLUE = 148
    LXB_CSS_COLOR_MINTCREAM = 149
    LXB_CSS_COLOR_MISTYROSE = 150
    LXB_CSS_COLOR_MOCCASIN = 151
    LXB_CSS_COLOR_NAVAJOWHITE = 152
    LXB_CSS_COLOR_NAVY = 153
    LXB_CSS_COLOR_OLDLACE = 154
    LXB_CSS_COLOR_OLIVE = 155
    LXB_CSS_COLOR_OLIVEDRAB = 156
    LXB_CSS_COLOR_ORANGE = 157
    LXB_CSS_COLOR_ORANGERED = 158
    LXB_CSS_COLOR_ORCHID = 159
    LXB_CSS_COLOR_PALEGOLDENROD = 160
    LXB_CSS_COLOR_PALEGREEN = 161
    LXB_CSS_COLOR_PALETURQUOISE = 162
    LXB_CSS_COLOR_PALEVIOLETRED = 163
    LXB_CSS_COLOR_PAPAYAWHIP = 164
    LXB_CSS_COLOR_PEACHPUFF = 165
    LXB_CSS_COLOR_PERU = 166
    LXB_CSS_COLOR_PINK = 167
    LXB_CSS_COLOR_PLUM = 168
    LXB_CSS_COLOR_POWDERBLUE = 169
    LXB_CSS_COLOR_PURPLE = 170
    LXB_CSS_COLOR_REBECCAPURPLE = 171
    LXB_CSS_COLOR_RED = 172
    LXB_CSS_COLOR_ROSYBROWN = 173
    LXB_CSS_COLOR_ROYALBLUE = 174
    LXB_CSS_COLOR_SADDLEBROWN = 175
    LXB_CSS_COLOR_SALMON = 176
    LXB_CSS_COLOR_SANDYBROWN = 177
    LXB_CSS_COLOR_SEAGREEN = 178
    LXB_CSS_COLOR_SEASHELL = 179
    LXB_CSS_COLOR_SIENNA = 180
    LXB_CSS_COLOR_SILVER = 181
    LXB_CSS_COLOR_SKYBLUE = 182
    LXB_CSS_COLOR_SLATEBLUE = 183
    LXB_CSS_COLOR_SLATEGRAY = 184
    LXB_CSS_COLOR_SLATEGREY = 185
    LXB_CSS_COLOR_SNOW = 186
    LXB_CSS_COLOR_SPRINGGREEN = 187
    LXB_CSS_COLOR_STEELBLUE = 188
    LXB_CSS_COLOR_TAN = 189
    LXB_CSS_COLOR_TEAL = 190
    LXB_CSS_COLOR_THISTLE = 191
    LXB_CSS_COLOR_TOMATO = 192
    LXB_CSS_COLOR_TURQUOISE = 193
    LXB_CSS_COLOR_VIOLET = 194
    LXB_CSS_COLOR_WHEAT = 195
    LXB_CSS_COLOR_WHITE = 196
    LXB_CSS_COLOR_WHITESMOKE = 197
    LXB_CSS_COLOR_YELLOW = 198
    LXB_CSS_COLOR_YELLOWGREEN = 199
    LXB_CSS_COLOR_CANVAS = 200
    LXB_CSS_COLOR_CANVASTEXT = 201
    LXB_CSS_COLOR_LINKTEXT = 202
    LXB_CSS_COLOR_VISITEDTEXT = 203
    LXB_CSS_COLOR_ACTIVETEXT = 204
    LXB_CSS_COLOR_BUTTONFACE = 205
    LXB_CSS_COLOR_BUTTONTEXT = 206
    LXB_CSS_COLOR_BUTTONBORDER = 207
    LXB_CSS_COLOR_FIELD = 208
    LXB_CSS_COLOR_FIELDTEXT = 209
    LXB_CSS_COLOR_HIGHLIGHT = 210
    LXB_CSS_COLOR_HIGHLIGHTTEXT = 211
    LXB_CSS_COLOR_SELECTEDITEM = 212
    LXB_CSS_COLOR_SELECTEDITEMTEXT = 213
    LXB_CSS_COLOR_MARK = 214
    LXB_CSS_COLOR_MARKTEXT = 215
    LXB_CSS_COLOR_GRAYTEXT = 216
    LXB_CSS_COLOR_ACCENTCOLOR = 217
    LXB_CSS_COLOR_ACCENTCOLORTEXT = 218
    LXB_CSS_COLOR_RGB = 219
    LXB_CSS_COLOR_RGBA = 220
    LXB_CSS_COLOR_HSL = 221
    LXB_CSS_COLOR_HSLA = 222
    LXB_CSS_COLOR_HWB = 223
    LXB_CSS_COLOR_LAB = 224
    LXB_CSS_COLOR_LCH = 225
    LXB_CSS_COLOR_OKLAB = 226
    LXB_CSS_COLOR_OKLCH = 227
    LXB_CSS_COLOR_COLOR = 228
end

const lxb_css_color_type_t = Cuint

@cenum __JL_Ctag_102::UInt32 begin
    LXB_CSS_DIRECTION_LTR = 229
    LXB_CSS_DIRECTION_RTL = 230
end

const lxb_css_direction_type_t = Cuint

@cenum __JL_Ctag_103::UInt32 begin
    LXB_CSS_DISPLAY_BLOCK = 231
    LXB_CSS_DISPLAY_INLINE = 232
    LXB_CSS_DISPLAY_RUN_IN = 233
    LXB_CSS_DISPLAY_FLOW = 234
    LXB_CSS_DISPLAY_FLOW_ROOT = 235
    LXB_CSS_DISPLAY_TABLE = 236
    LXB_CSS_DISPLAY_FLEX = 237
    LXB_CSS_DISPLAY_GRID = 238
    LXB_CSS_DISPLAY_RUBY = 239
    LXB_CSS_DISPLAY_LIST_ITEM = 240
    LXB_CSS_DISPLAY_TABLE_ROW_GROUP = 241
    LXB_CSS_DISPLAY_TABLE_HEADER_GROUP = 242
    LXB_CSS_DISPLAY_TABLE_FOOTER_GROUP = 243
    LXB_CSS_DISPLAY_TABLE_ROW = 244
    LXB_CSS_DISPLAY_TABLE_CELL = 245
    LXB_CSS_DISPLAY_TABLE_COLUMN_GROUP = 246
    LXB_CSS_DISPLAY_TABLE_COLUMN = 247
    LXB_CSS_DISPLAY_TABLE_CAPTION = 248
    LXB_CSS_DISPLAY_RUBY_BASE = 249
    LXB_CSS_DISPLAY_RUBY_TEXT = 250
    LXB_CSS_DISPLAY_RUBY_BASE_CONTAINER = 251
    LXB_CSS_DISPLAY_RUBY_TEXT_CONTAINER = 252
    LXB_CSS_DISPLAY_CONTENTS = 253
    LXB_CSS_DISPLAY_NONE = 31
    LXB_CSS_DISPLAY_INLINE_BLOCK = 254
    LXB_CSS_DISPLAY_INLINE_TABLE = 255
    LXB_CSS_DISPLAY_INLINE_FLEX = 256
    LXB_CSS_DISPLAY_INLINE_GRID = 257
end

const lxb_css_display_type_t = Cuint

@cenum __JL_Ctag_104::UInt32 begin
    LXB_CSS_DOMINANT_BASELINE_AUTO = 12
    LXB_CSS_DOMINANT_BASELINE_TEXT_BOTTOM = 13
    LXB_CSS_DOMINANT_BASELINE_ALPHABETIC = 14
    LXB_CSS_DOMINANT_BASELINE_IDEOGRAPHIC = 15
    LXB_CSS_DOMINANT_BASELINE_MIDDLE = 16
    LXB_CSS_DOMINANT_BASELINE_CENTRAL = 17
    LXB_CSS_DOMINANT_BASELINE_MATHEMATICAL = 18
    LXB_CSS_DOMINANT_BASELINE_HANGING = 258
    LXB_CSS_DOMINANT_BASELINE_TEXT_TOP = 19
end

const lxb_css_dominant_baseline_type_t = Cuint

@cenum __JL_Ctag_105::UInt32 begin
    LXB_CSS_FLEX_NONE = 31
end

const lxb_css_flex_type_t = Cuint

@cenum __JL_Ctag_106::UInt32 begin
    LXB_CSS_FLEX_BASIS_CONTENT = 259
end

const lxb_css_flex_basis_type_t = Cuint

@cenum __JL_Ctag_107::UInt32 begin
    LXB_CSS_FLEX_DIRECTION_ROW = 260
    LXB_CSS_FLEX_DIRECTION_ROW_REVERSE = 261
    LXB_CSS_FLEX_DIRECTION_COLUMN = 262
    LXB_CSS_FLEX_DIRECTION_COLUMN_REVERSE = 263
end

const lxb_css_flex_direction_type_t = Cuint

@cenum __JL_Ctag_108::UInt32 begin
    LXB_CSS_FLEX_GROW__NUMBER = 264
end

const lxb_css_flex_grow_type_t = Cuint

@cenum __JL_Ctag_109::UInt32 begin
    LXB_CSS_FLEX_SHRINK__NUMBER = 264
end

const lxb_css_flex_shrink_type_t = Cuint

@cenum __JL_Ctag_110::UInt32 begin
    LXB_CSS_FLEX_WRAP_NOWRAP = 265
    LXB_CSS_FLEX_WRAP_WRAP = 266
    LXB_CSS_FLEX_WRAP_WRAP_REVERSE = 267
end

const lxb_css_flex_wrap_type_t = Cuint

@cenum __JL_Ctag_111::UInt32 begin
    LXB_CSS_FLOAT_BLOCK_START = 45
    LXB_CSS_FLOAT_BLOCK_END = 46
    LXB_CSS_FLOAT_INLINE_START = 43
    LXB_CSS_FLOAT_INLINE_END = 44
    LXB_CSS_FLOAT_SNAP_BLOCK = 268
    LXB_CSS_FLOAT_START = 269
    LXB_CSS_FLOAT_END = 270
    LXB_CSS_FLOAT_NEAR = 271
    LXB_CSS_FLOAT_SNAP_INLINE = 272
    LXB_CSS_FLOAT_LEFT = 47
    LXB_CSS_FLOAT_RIGHT = 48
    LXB_CSS_FLOAT_TOP = 24
    LXB_CSS_FLOAT_BOTTOM = 25
    LXB_CSS_FLOAT_NONE = 31
end

const lxb_css_float_type_t = Cuint

@cenum __JL_Ctag_112::UInt32 begin
    LXB_CSS_FLOAT_DEFER__INTEGER = 273
    LXB_CSS_FLOAT_DEFER_LAST = 27
    LXB_CSS_FLOAT_DEFER_NONE = 31
end

const lxb_css_float_defer_type_t = Cuint

@cenum __JL_Ctag_113::UInt32 begin
    LXB_CSS_FLOAT_OFFSET__LENGTH = 20
    LXB_CSS_FLOAT_OFFSET__PERCENTAGE = 21
end

const lxb_css_float_offset_type_t = Cuint

@cenum __JL_Ctag_114::UInt32 begin
    LXB_CSS_FLOAT_REFERENCE_INLINE = 232
    LXB_CSS_FLOAT_REFERENCE_COLUMN = 262
    LXB_CSS_FLOAT_REFERENCE_REGION = 274
    LXB_CSS_FLOAT_REFERENCE_PAGE = 275
end

const lxb_css_float_reference_type_t = Cuint

@cenum __JL_Ctag_115::UInt32 begin
    LXB_CSS_FONT_FAMILY_SERIF = 276
    LXB_CSS_FONT_FAMILY_SANS_SERIF = 277
    LXB_CSS_FONT_FAMILY_CURSIVE = 278
    LXB_CSS_FONT_FAMILY_FANTASY = 279
    LXB_CSS_FONT_FAMILY_MONOSPACE = 280
    LXB_CSS_FONT_FAMILY_SYSTEM_UI = 281
    LXB_CSS_FONT_FAMILY_EMOJI = 282
    LXB_CSS_FONT_FAMILY_MATH = 283
    LXB_CSS_FONT_FAMILY_FANGSONG = 284
    LXB_CSS_FONT_FAMILY_UI_SERIF = 285
    LXB_CSS_FONT_FAMILY_UI_SANS_SERIF = 286
    LXB_CSS_FONT_FAMILY_UI_MONOSPACE = 287
    LXB_CSS_FONT_FAMILY_UI_ROUNDED = 288
end

const lxb_css_font_family_type_t = Cuint

@cenum __JL_Ctag_116::UInt32 begin
    LXB_CSS_FONT_SIZE_XX_SMALL = 289
    LXB_CSS_FONT_SIZE_X_SMALL = 290
    LXB_CSS_FONT_SIZE_SMALL = 291
    LXB_CSS_FONT_SIZE_MEDIUM = 29
    LXB_CSS_FONT_SIZE_LARGE = 292
    LXB_CSS_FONT_SIZE_X_LARGE = 293
    LXB_CSS_FONT_SIZE_XX_LARGE = 294
    LXB_CSS_FONT_SIZE_XXX_LARGE = 295
    LXB_CSS_FONT_SIZE_LARGER = 296
    LXB_CSS_FONT_SIZE_SMALLER = 297
    LXB_CSS_FONT_SIZE_MATH = 283
    LXB_CSS_FONT_SIZE__LENGTH = 20
end

const lxb_css_font_size_type_t = Cuint

@cenum __JL_Ctag_117::UInt32 begin
    LXB_CSS_FONT_STRETCH_NORMAL = 298
    LXB_CSS_FONT_STRETCH__PERCENTAGE = 21
    LXB_CSS_FONT_STRETCH_ULTRA_CONDENSED = 299
    LXB_CSS_FONT_STRETCH_EXTRA_CONDENSED = 300
    LXB_CSS_FONT_STRETCH_CONDENSED = 301
    LXB_CSS_FONT_STRETCH_SEMI_CONDENSED = 302
    LXB_CSS_FONT_STRETCH_SEMI_EXPANDED = 303
    LXB_CSS_FONT_STRETCH_EXPANDED = 304
    LXB_CSS_FONT_STRETCH_EXTRA_EXPANDED = 305
    LXB_CSS_FONT_STRETCH_ULTRA_EXPANDED = 306
end

const lxb_css_font_stretch_type_t = Cuint

@cenum __JL_Ctag_118::UInt32 begin
    LXB_CSS_FONT_STYLE_NORMAL = 298
    LXB_CSS_FONT_STYLE_ITALIC = 307
    LXB_CSS_FONT_STYLE_OBLIQUE = 308
end

const lxb_css_font_style_type_t = Cuint

@cenum __JL_Ctag_119::UInt32 begin
    LXB_CSS_FONT_WEIGHT_NORMAL = 298
    LXB_CSS_FONT_WEIGHT_BOLD = 309
    LXB_CSS_FONT_WEIGHT__NUMBER = 264
    LXB_CSS_FONT_WEIGHT_BOLDER = 310
    LXB_CSS_FONT_WEIGHT_LIGHTER = 311
end

const lxb_css_font_weight_type_t = Cuint

@cenum __JL_Ctag_120::UInt32 begin
    LXB_CSS_HANGING_PUNCTUATION_NONE = 31
    LXB_CSS_HANGING_PUNCTUATION_FIRST = 26
    LXB_CSS_HANGING_PUNCTUATION_FORCE_END = 312
    LXB_CSS_HANGING_PUNCTUATION_ALLOW_END = 313
    LXB_CSS_HANGING_PUNCTUATION_LAST = 27
end

const lxb_css_hanging_punctuation_type_t = Cuint

@cenum __JL_Ctag_121::UInt32 begin
    LXB_CSS_HEIGHT_AUTO = 12
    LXB_CSS_HEIGHT_MIN_CONTENT = 314
    LXB_CSS_HEIGHT_MAX_CONTENT = 315
    LXB_CSS_HEIGHT__LENGTH = 20
    LXB_CSS_HEIGHT__PERCENTAGE = 21
    LXB_CSS_HEIGHT__NUMBER = 264
    LXB_CSS_HEIGHT__ANGLE = 316
end

const lxb_css_height_type_t = Cuint

@cenum __JL_Ctag_122::UInt32 begin
    LXB_CSS_HYPHENS_NONE = 31
    LXB_CSS_HYPHENS_MANUAL = 317
    LXB_CSS_HYPHENS_AUTO = 12
end

const lxb_css_hyphens_type_t = Cuint

@cenum __JL_Ctag_123::UInt32 begin
    LXB_CSS_INSET_BLOCK_END_AUTO = 12
    LXB_CSS_INSET_BLOCK_END__LENGTH = 20
    LXB_CSS_INSET_BLOCK_END__PERCENTAGE = 21
end

const lxb_css_inset_block_end_type_t = Cuint

@cenum __JL_Ctag_124::UInt32 begin
    LXB_CSS_INSET_BLOCK_START_AUTO = 12
    LXB_CSS_INSET_BLOCK_START__LENGTH = 20
    LXB_CSS_INSET_BLOCK_START__PERCENTAGE = 21
end

const lxb_css_inset_block_start_type_t = Cuint

@cenum __JL_Ctag_125::UInt32 begin
    LXB_CSS_INSET_INLINE_END_AUTO = 12
    LXB_CSS_INSET_INLINE_END__LENGTH = 20
    LXB_CSS_INSET_INLINE_END__PERCENTAGE = 21
end

const lxb_css_inset_inline_end_type_t = Cuint

@cenum __JL_Ctag_126::UInt32 begin
    LXB_CSS_INSET_INLINE_START_AUTO = 12
    LXB_CSS_INSET_INLINE_START__LENGTH = 20
    LXB_CSS_INSET_INLINE_START__PERCENTAGE = 21
end

const lxb_css_inset_inline_start_type_t = Cuint

@cenum __JL_Ctag_127::UInt32 begin
    LXB_CSS_JUSTIFY_CONTENT_FLEX_START = 5
    LXB_CSS_JUSTIFY_CONTENT_FLEX_END = 6
    LXB_CSS_JUSTIFY_CONTENT_CENTER = 7
    LXB_CSS_JUSTIFY_CONTENT_SPACE_BETWEEN = 8
    LXB_CSS_JUSTIFY_CONTENT_SPACE_AROUND = 9
end

const lxb_css_justify_content_type_t = Cuint

@cenum __JL_Ctag_128::UInt32 begin
    LXB_CSS_LEFT_AUTO = 12
    LXB_CSS_LEFT__LENGTH = 20
    LXB_CSS_LEFT__PERCENTAGE = 21
end

const lxb_css_left_type_t = Cuint

@cenum __JL_Ctag_129::UInt32 begin
    LXB_CSS_LETTER_SPACING_NORMAL = 298
    LXB_CSS_LETTER_SPACING__LENGTH = 20
end

const lxb_css_letter_spacing_type_t = Cuint

@cenum __JL_Ctag_130::UInt32 begin
    LXB_CSS_LINE_BREAK_AUTO = 12
    LXB_CSS_LINE_BREAK_LOOSE = 318
    LXB_CSS_LINE_BREAK_NORMAL = 298
    LXB_CSS_LINE_BREAK_STRICT = 319
    LXB_CSS_LINE_BREAK_ANYWHERE = 320
end

const lxb_css_line_break_type_t = Cuint

@cenum __JL_Ctag_131::UInt32 begin
    LXB_CSS_LINE_HEIGHT_NORMAL = 298
    LXB_CSS_LINE_HEIGHT__NUMBER = 264
    LXB_CSS_LINE_HEIGHT__LENGTH = 20
    LXB_CSS_LINE_HEIGHT__PERCENTAGE = 21
end

const lxb_css_line_height_type_t = Cuint

@cenum __JL_Ctag_132::UInt32 begin
    LXB_CSS_MARGIN_AUTO = 12
    LXB_CSS_MARGIN__LENGTH = 20
    LXB_CSS_MARGIN__PERCENTAGE = 21
end

const lxb_css_margin_type_t = Cuint

@cenum __JL_Ctag_133::UInt32 begin
    LXB_CSS_MARGIN_BOTTOM_AUTO = 12
    LXB_CSS_MARGIN_BOTTOM__LENGTH = 20
    LXB_CSS_MARGIN_BOTTOM__PERCENTAGE = 21
end

const lxb_css_margin_bottom_type_t = Cuint

@cenum __JL_Ctag_134::UInt32 begin
    LXB_CSS_MARGIN_LEFT_AUTO = 12
    LXB_CSS_MARGIN_LEFT__LENGTH = 20
    LXB_CSS_MARGIN_LEFT__PERCENTAGE = 21
end

const lxb_css_margin_left_type_t = Cuint

@cenum __JL_Ctag_135::UInt32 begin
    LXB_CSS_MARGIN_RIGHT_AUTO = 12
    LXB_CSS_MARGIN_RIGHT__LENGTH = 20
    LXB_CSS_MARGIN_RIGHT__PERCENTAGE = 21
end

const lxb_css_margin_right_type_t = Cuint

@cenum __JL_Ctag_136::UInt32 begin
    LXB_CSS_MARGIN_TOP_AUTO = 12
    LXB_CSS_MARGIN_TOP__LENGTH = 20
    LXB_CSS_MARGIN_TOP__PERCENTAGE = 21
end

const lxb_css_margin_top_type_t = Cuint

@cenum __JL_Ctag_137::UInt32 begin
    LXB_CSS_MAX_HEIGHT_NONE = 31
    LXB_CSS_MAX_HEIGHT_MIN_CONTENT = 314
    LXB_CSS_MAX_HEIGHT_MAX_CONTENT = 315
    LXB_CSS_MAX_HEIGHT__LENGTH = 20
    LXB_CSS_MAX_HEIGHT__PERCENTAGE = 21
    LXB_CSS_MAX_HEIGHT__NUMBER = 264
    LXB_CSS_MAX_HEIGHT__ANGLE = 316
end

const lxb_css_max_height_type_t = Cuint

@cenum __JL_Ctag_138::UInt32 begin
    LXB_CSS_MAX_WIDTH_NONE = 31
    LXB_CSS_MAX_WIDTH_MIN_CONTENT = 314
    LXB_CSS_MAX_WIDTH_MAX_CONTENT = 315
    LXB_CSS_MAX_WIDTH__LENGTH = 20
    LXB_CSS_MAX_WIDTH__PERCENTAGE = 21
    LXB_CSS_MAX_WIDTH__NUMBER = 264
    LXB_CSS_MAX_WIDTH__ANGLE = 316
end

const lxb_css_max_width_type_t = Cuint

@cenum __JL_Ctag_139::UInt32 begin
    LXB_CSS_MIN_HEIGHT_AUTO = 12
    LXB_CSS_MIN_HEIGHT_MIN_CONTENT = 314
    LXB_CSS_MIN_HEIGHT_MAX_CONTENT = 315
    LXB_CSS_MIN_HEIGHT__LENGTH = 20
    LXB_CSS_MIN_HEIGHT__PERCENTAGE = 21
    LXB_CSS_MIN_HEIGHT__NUMBER = 264
    LXB_CSS_MIN_HEIGHT__ANGLE = 316
end

const lxb_css_min_height_type_t = Cuint

@cenum __JL_Ctag_140::UInt32 begin
    LXB_CSS_MIN_WIDTH_AUTO = 12
    LXB_CSS_MIN_WIDTH_MIN_CONTENT = 314
    LXB_CSS_MIN_WIDTH_MAX_CONTENT = 315
    LXB_CSS_MIN_WIDTH__LENGTH = 20
    LXB_CSS_MIN_WIDTH__PERCENTAGE = 21
    LXB_CSS_MIN_WIDTH__NUMBER = 264
    LXB_CSS_MIN_WIDTH__ANGLE = 316
end

const lxb_css_min_width_type_t = Cuint

@cenum __JL_Ctag_141::UInt32 begin
    LXB_CSS_OPACITY__NUMBER = 264
    LXB_CSS_OPACITY__PERCENTAGE = 21
end

const lxb_css_opacity_type_t = Cuint

@cenum __JL_Ctag_142::UInt32 begin
    LXB_CSS_ORDER__INTEGER = 273
end

const lxb_css_order_type_t = Cuint

@cenum __JL_Ctag_143::UInt32 begin
    LXB_CSS_OVERFLOW_BLOCK_VISIBLE = 321
    LXB_CSS_OVERFLOW_BLOCK_HIDDEN = 32
    LXB_CSS_OVERFLOW_BLOCK_CLIP = 322
    LXB_CSS_OVERFLOW_BLOCK_SCROLL = 323
    LXB_CSS_OVERFLOW_BLOCK_AUTO = 12
end

const lxb_css_overflow_block_type_t = Cuint

@cenum __JL_Ctag_144::UInt32 begin
    LXB_CSS_OVERFLOW_INLINE_VISIBLE = 321
    LXB_CSS_OVERFLOW_INLINE_HIDDEN = 32
    LXB_CSS_OVERFLOW_INLINE_CLIP = 322
    LXB_CSS_OVERFLOW_INLINE_SCROLL = 323
    LXB_CSS_OVERFLOW_INLINE_AUTO = 12
end

const lxb_css_overflow_inline_type_t = Cuint

@cenum __JL_Ctag_145::UInt32 begin
    LXB_CSS_OVERFLOW_WRAP_NORMAL = 298
    LXB_CSS_OVERFLOW_WRAP_BREAK_WORD = 324
    LXB_CSS_OVERFLOW_WRAP_ANYWHERE = 320
end

const lxb_css_overflow_wrap_type_t = Cuint

@cenum __JL_Ctag_146::UInt32 begin
    LXB_CSS_OVERFLOW_X_VISIBLE = 321
    LXB_CSS_OVERFLOW_X_HIDDEN = 32
    LXB_CSS_OVERFLOW_X_CLIP = 322
    LXB_CSS_OVERFLOW_X_SCROLL = 323
    LXB_CSS_OVERFLOW_X_AUTO = 12
end

const lxb_css_overflow_x_type_t = Cuint

@cenum __JL_Ctag_147::UInt32 begin
    LXB_CSS_OVERFLOW_Y_VISIBLE = 321
    LXB_CSS_OVERFLOW_Y_HIDDEN = 32
    LXB_CSS_OVERFLOW_Y_CLIP = 322
    LXB_CSS_OVERFLOW_Y_SCROLL = 323
    LXB_CSS_OVERFLOW_Y_AUTO = 12
end

const lxb_css_overflow_y_type_t = Cuint

@cenum __JL_Ctag_148::UInt32 begin
    LXB_CSS_PADDING_AUTO = 12
    LXB_CSS_PADDING__LENGTH = 20
    LXB_CSS_PADDING__PERCENTAGE = 21
end

const lxb_css_padding_type_t = Cuint

@cenum __JL_Ctag_149::UInt32 begin
    LXB_CSS_PADDING_BOTTOM_AUTO = 12
    LXB_CSS_PADDING_BOTTOM__LENGTH = 20
    LXB_CSS_PADDING_BOTTOM__PERCENTAGE = 21
end

const lxb_css_padding_bottom_type_t = Cuint

@cenum __JL_Ctag_150::UInt32 begin
    LXB_CSS_PADDING_LEFT_AUTO = 12
    LXB_CSS_PADDING_LEFT__LENGTH = 20
    LXB_CSS_PADDING_LEFT__PERCENTAGE = 21
end

const lxb_css_padding_left_type_t = Cuint

@cenum __JL_Ctag_151::UInt32 begin
    LXB_CSS_PADDING_RIGHT_AUTO = 12
    LXB_CSS_PADDING_RIGHT__LENGTH = 20
    LXB_CSS_PADDING_RIGHT__PERCENTAGE = 21
end

const lxb_css_padding_right_type_t = Cuint

@cenum __JL_Ctag_152::UInt32 begin
    LXB_CSS_PADDING_TOP_AUTO = 12
    LXB_CSS_PADDING_TOP__LENGTH = 20
    LXB_CSS_PADDING_TOP__PERCENTAGE = 21
end

const lxb_css_padding_top_type_t = Cuint

@cenum __JL_Ctag_153::UInt32 begin
    LXB_CSS_POSITION_STATIC = 325
    LXB_CSS_POSITION_RELATIVE = 326
    LXB_CSS_POSITION_ABSOLUTE = 327
    LXB_CSS_POSITION_STICKY = 328
    LXB_CSS_POSITION_FIXED = 329
end

const lxb_css_position_type_t = Cuint

@cenum __JL_Ctag_154::UInt32 begin
    LXB_CSS_RIGHT_AUTO = 12
    LXB_CSS_RIGHT__LENGTH = 20
    LXB_CSS_RIGHT__PERCENTAGE = 21
end

const lxb_css_right_type_t = Cuint

@cenum __JL_Ctag_155::UInt32 begin
    LXB_CSS_TAB_SIZE__NUMBER = 264
    LXB_CSS_TAB_SIZE__LENGTH = 20
end

const lxb_css_tab_size_type_t = Cuint

@cenum __JL_Ctag_156::UInt32 begin
    LXB_CSS_TEXT_ALIGN_START = 269
    LXB_CSS_TEXT_ALIGN_END = 270
    LXB_CSS_TEXT_ALIGN_LEFT = 47
    LXB_CSS_TEXT_ALIGN_RIGHT = 48
    LXB_CSS_TEXT_ALIGN_CENTER = 7
    LXB_CSS_TEXT_ALIGN_JUSTIFY = 330
    LXB_CSS_TEXT_ALIGN_MATCH_PARENT = 331
    LXB_CSS_TEXT_ALIGN_JUSTIFY_ALL = 332
end

const lxb_css_text_align_type_t = Cuint

@cenum __JL_Ctag_157::UInt32 begin
    LXB_CSS_TEXT_ALIGN_ALL_START = 269
    LXB_CSS_TEXT_ALIGN_ALL_END = 270
    LXB_CSS_TEXT_ALIGN_ALL_LEFT = 47
    LXB_CSS_TEXT_ALIGN_ALL_RIGHT = 48
    LXB_CSS_TEXT_ALIGN_ALL_CENTER = 7
    LXB_CSS_TEXT_ALIGN_ALL_JUSTIFY = 330
    LXB_CSS_TEXT_ALIGN_ALL_MATCH_PARENT = 331
end

const lxb_css_text_align_all_type_t = Cuint

@cenum __JL_Ctag_158::UInt32 begin
    LXB_CSS_TEXT_ALIGN_LAST_AUTO = 12
    LXB_CSS_TEXT_ALIGN_LAST_START = 269
    LXB_CSS_TEXT_ALIGN_LAST_END = 270
    LXB_CSS_TEXT_ALIGN_LAST_LEFT = 47
    LXB_CSS_TEXT_ALIGN_LAST_RIGHT = 48
    LXB_CSS_TEXT_ALIGN_LAST_CENTER = 7
    LXB_CSS_TEXT_ALIGN_LAST_JUSTIFY = 330
    LXB_CSS_TEXT_ALIGN_LAST_MATCH_PARENT = 331
end

const lxb_css_text_align_last_type_t = Cuint

@cenum __JL_Ctag_159::UInt32 begin
    LXB_CSS_TEXT_COMBINE_UPRIGHT_NONE = 31
    LXB_CSS_TEXT_COMBINE_UPRIGHT_ALL = 333
    LXB_CSS_TEXT_COMBINE_UPRIGHT_DIGITS = 334
end

const lxb_css_text_combine_upright_type_t = Cuint

@cenum __JL_Ctag_160::UInt32 begin
    LXB_CSS_TEXT_DECORATION_LINE_NONE = 31
    LXB_CSS_TEXT_DECORATION_LINE_UNDERLINE = 335
    LXB_CSS_TEXT_DECORATION_LINE_OVERLINE = 336
    LXB_CSS_TEXT_DECORATION_LINE_LINE_THROUGH = 337
    LXB_CSS_TEXT_DECORATION_LINE_BLINK = 338
end

const lxb_css_text_decoration_line_type_t = Cuint

@cenum __JL_Ctag_161::UInt32 begin
    LXB_CSS_TEXT_DECORATION_STYLE_SOLID = 35
    LXB_CSS_TEXT_DECORATION_STYLE_DOUBLE = 36
    LXB_CSS_TEXT_DECORATION_STYLE_DOTTED = 33
    LXB_CSS_TEXT_DECORATION_STYLE_DASHED = 34
    LXB_CSS_TEXT_DECORATION_STYLE_WAVY = 339
end

const lxb_css_text_decoration_style_type_t = Cuint

@cenum __JL_Ctag_162::UInt32 begin
    LXB_CSS_TEXT_INDENT__LENGTH = 20
    LXB_CSS_TEXT_INDENT__PERCENTAGE = 21
    LXB_CSS_TEXT_INDENT_HANGING = 258
    LXB_CSS_TEXT_INDENT_EACH_LINE = 340
end

const lxb_css_text_indent_type_t = Cuint

@cenum __JL_Ctag_163::UInt32 begin
    LXB_CSS_TEXT_JUSTIFY_AUTO = 12
    LXB_CSS_TEXT_JUSTIFY_NONE = 31
    LXB_CSS_TEXT_JUSTIFY_INTER_WORD = 341
    LXB_CSS_TEXT_JUSTIFY_INTER_CHARACTER = 342
end

const lxb_css_text_justify_type_t = Cuint

@cenum __JL_Ctag_164::UInt32 begin
    LXB_CSS_TEXT_ORIENTATION_MIXED = 343
    LXB_CSS_TEXT_ORIENTATION_UPRIGHT = 344
    LXB_CSS_TEXT_ORIENTATION_SIDEWAYS = 345
end

const lxb_css_text_orientation_type_t = Cuint

@cenum __JL_Ctag_165::UInt32 begin
    LXB_CSS_TEXT_OVERFLOW_CLIP = 322
    LXB_CSS_TEXT_OVERFLOW_ELLIPSIS = 346
end

const lxb_css_text_overflow_type_t = Cuint

@cenum __JL_Ctag_166::UInt32 begin
    LXB_CSS_TEXT_TRANSFORM_NONE = 31
    LXB_CSS_TEXT_TRANSFORM_CAPITALIZE = 347
    LXB_CSS_TEXT_TRANSFORM_UPPERCASE = 348
    LXB_CSS_TEXT_TRANSFORM_LOWERCASE = 349
    LXB_CSS_TEXT_TRANSFORM_FULL_WIDTH = 350
    LXB_CSS_TEXT_TRANSFORM_FULL_SIZE_KANA = 351
end

const lxb_css_text_transform_type_t = Cuint

@cenum __JL_Ctag_167::UInt32 begin
    LXB_CSS_TOP_AUTO = 12
    LXB_CSS_TOP__LENGTH = 20
    LXB_CSS_TOP__PERCENTAGE = 21
end

const lxb_css_top_type_t = Cuint

@cenum __JL_Ctag_168::UInt32 begin
    LXB_CSS_UNICODE_BIDI_NORMAL = 298
    LXB_CSS_UNICODE_BIDI_EMBED = 352
    LXB_CSS_UNICODE_BIDI_ISOLATE = 353
    LXB_CSS_UNICODE_BIDI_BIDI_OVERRIDE = 354
    LXB_CSS_UNICODE_BIDI_ISOLATE_OVERRIDE = 355
    LXB_CSS_UNICODE_BIDI_PLAINTEXT = 356
end

const lxb_css_unicode_bidi_type_t = Cuint

@cenum __JL_Ctag_169::UInt32 begin
    LXB_CSS_VERTICAL_ALIGN_FIRST = 26
    LXB_CSS_VERTICAL_ALIGN_LAST = 27
end

const lxb_css_vertical_align_type_t = Cuint

@cenum __JL_Ctag_170::UInt32 begin
    LXB_CSS_VISIBILITY_VISIBLE = 321
    LXB_CSS_VISIBILITY_HIDDEN = 32
    LXB_CSS_VISIBILITY_COLLAPSE = 357
end

const lxb_css_visibility_type_t = Cuint

@cenum __JL_Ctag_171::UInt32 begin
    LXB_CSS_WHITE_SPACE_NORMAL = 298
    LXB_CSS_WHITE_SPACE_PRE = 358
    LXB_CSS_WHITE_SPACE_NOWRAP = 265
    LXB_CSS_WHITE_SPACE_PRE_WRAP = 359
    LXB_CSS_WHITE_SPACE_BREAK_SPACES = 360
    LXB_CSS_WHITE_SPACE_PRE_LINE = 361
end

const lxb_css_white_space_type_t = Cuint

@cenum __JL_Ctag_172::UInt32 begin
    LXB_CSS_WIDTH_AUTO = 12
    LXB_CSS_WIDTH_MIN_CONTENT = 314
    LXB_CSS_WIDTH_MAX_CONTENT = 315
    LXB_CSS_WIDTH__LENGTH = 20
    LXB_CSS_WIDTH__PERCENTAGE = 21
    LXB_CSS_WIDTH__NUMBER = 264
    LXB_CSS_WIDTH__ANGLE = 316
end

const lxb_css_width_type_t = Cuint

@cenum __JL_Ctag_173::UInt32 begin
    LXB_CSS_WORD_BREAK_NORMAL = 298
    LXB_CSS_WORD_BREAK_KEEP_ALL = 362
    LXB_CSS_WORD_BREAK_BREAK_ALL = 363
    LXB_CSS_WORD_BREAK_BREAK_WORD = 324
end

const lxb_css_word_break_type_t = Cuint

@cenum __JL_Ctag_174::UInt32 begin
    LXB_CSS_WORD_SPACING_NORMAL = 298
    LXB_CSS_WORD_SPACING__LENGTH = 20
end

const lxb_css_word_spacing_type_t = Cuint

@cenum __JL_Ctag_175::UInt32 begin
    LXB_CSS_WORD_WRAP_NORMAL = 298
    LXB_CSS_WORD_WRAP_BREAK_WORD = 324
    LXB_CSS_WORD_WRAP_ANYWHERE = 320
end

const lxb_css_word_wrap_type_t = Cuint

@cenum __JL_Ctag_176::UInt32 begin
    LXB_CSS_WRAP_FLOW_AUTO = 12
    LXB_CSS_WRAP_FLOW_BOTH = 364
    LXB_CSS_WRAP_FLOW_START = 269
    LXB_CSS_WRAP_FLOW_END = 270
    LXB_CSS_WRAP_FLOW_MINIMUM = 365
    LXB_CSS_WRAP_FLOW_MAXIMUM = 366
    LXB_CSS_WRAP_FLOW_CLEAR = 367
end

const lxb_css_wrap_flow_type_t = Cuint

@cenum __JL_Ctag_177::UInt32 begin
    LXB_CSS_WRAP_THROUGH_WRAP = 266
    LXB_CSS_WRAP_THROUGH_NONE = 31
end

const lxb_css_wrap_through_type_t = Cuint

@cenum __JL_Ctag_178::UInt32 begin
    LXB_CSS_WRITING_MODE_HORIZONTAL_TB = 368
    LXB_CSS_WRITING_MODE_VERTICAL_RL = 369
    LXB_CSS_WRITING_MODE_VERTICAL_LR = 370
    LXB_CSS_WRITING_MODE_SIDEWAYS_RL = 371
    LXB_CSS_WRITING_MODE_SIDEWAYS_LR = 372
end

const lxb_css_writing_mode_type_t = Cuint

@cenum __JL_Ctag_179::UInt32 begin
    LXB_CSS_Z_INDEX_AUTO = 12
    LXB_CSS_Z_INDEX__INTEGER = 273
end

const lxb_css_z_index_type_t = Cuint

struct lxb_css_property__undef_t
    type::lxb_css_property_type_t
    value::lexbor_str_t
end

struct lxb_css_property__custom_t
    name::lexbor_str_t
    value::lexbor_str_t
end

struct lxb_css_property_display_t
    a::lxb_css_display_type_t
    b::lxb_css_display_type_t
    c::lxb_css_display_type_t
end

const lxb_css_property_order_t = lxb_css_value_integer_type_t

struct lxb_css_property_visibility_t
    type::lxb_css_visibility_type_t
end

const lxb_css_property_width_t = lxb_css_value_length_percentage_t

const lxb_css_property_height_t = lxb_css_value_length_percentage_t

const lxb_css_property_min_width_t = lxb_css_value_length_percentage_t

const lxb_css_property_min_height_t = lxb_css_value_length_percentage_t

const lxb_css_property_max_width_t = lxb_css_value_length_percentage_t

const lxb_css_property_max_height_t = lxb_css_value_length_percentage_t

const lxb_css_property_margin_top_t = lxb_css_value_length_percentage_t

const lxb_css_property_margin_right_t = lxb_css_value_length_percentage_t

const lxb_css_property_margin_bottom_t = lxb_css_value_length_percentage_t

const lxb_css_property_margin_left_t = lxb_css_value_length_percentage_t

const lxb_css_property_padding_top_t = lxb_css_value_length_percentage_t

const lxb_css_property_padding_right_t = lxb_css_value_length_percentage_t

const lxb_css_property_padding_bottom_t = lxb_css_value_length_percentage_t

const lxb_css_property_padding_left_t = lxb_css_value_length_percentage_t

struct lxb_css_property_box_sizing_t
    type::lxb_css_box_sizing_type_t
end

struct lxb_css_property_margin_t
    top::lxb_css_property_margin_top_t
    right::lxb_css_property_margin_right_t
    bottom::lxb_css_property_margin_bottom_t
    left::lxb_css_property_margin_left_t
end

struct lxb_css_property_padding_t
    top::lxb_css_property_padding_top_t
    right::lxb_css_property_padding_right_t
    bottom::lxb_css_property_padding_bottom_t
    left::lxb_css_property_padding_left_t
end

struct lxb_css_property_border_t
    style::lxb_css_value_type_t
    width::lxb_css_value_length_type_t
    color::lxb_css_value_color_t
end

const lxb_css_property_border_top_t = lxb_css_property_border_t

const lxb_css_property_border_right_t = lxb_css_property_border_t

const lxb_css_property_border_bottom_t = lxb_css_property_border_t

const lxb_css_property_border_left_t = lxb_css_property_border_t

const lxb_css_property_border_top_color_t = lxb_css_value_color_t

const lxb_css_property_border_right_color_t = lxb_css_value_color_t

const lxb_css_property_border_bottom_color_t = lxb_css_value_color_t

const lxb_css_property_border_left_color_t = lxb_css_value_color_t

const lxb_css_property_background_color_t = lxb_css_value_color_t

const lxb_css_property_color_t = lxb_css_value_color_t

const lxb_css_property_opacity_t = lxb_css_value_number_percentage_t

struct lxb_css_property_position_t
    type::lxb_css_position_type_t
end

const lxb_css_property_top_t = lxb_css_value_length_percentage_t

const lxb_css_property_right_t = lxb_css_value_length_percentage_t

const lxb_css_property_bottom_t = lxb_css_value_length_percentage_t

const lxb_css_property_left_t = lxb_css_value_length_percentage_t

const lxb_css_property_inset_block_start_t = lxb_css_value_length_percentage_t

const lxb_css_property_inset_inline_start_t = lxb_css_value_length_percentage_t

const lxb_css_property_inset_block_end_t = lxb_css_value_length_percentage_t

const lxb_css_property_inset_inline_end_t = lxb_css_value_length_percentage_t

struct lxb_css_property_text_transform_t
    type_case::lxb_css_text_transform_type_t
    full_width::lxb_css_text_transform_type_t
    full_size_kana::lxb_css_text_transform_type_t
end

struct lxb_css_property_text_align_t
    type::lxb_css_text_align_type_t
end

struct lxb_css_property_text_align_all_t
    type::lxb_css_text_align_all_type_t
end

struct lxb_css_property_text_align_last_t
    type::lxb_css_text_align_last_type_t
end

struct lxb_css_property_text_justify_t
    type::lxb_css_text_justify_type_t
end

struct lxb_css_property_text_indent_t
    length::lxb_css_value_length_percentage_t
    type::lxb_css_text_indent_type_t
    hanging::lxb_css_text_indent_type_t
    each_line::lxb_css_text_indent_type_t
end

struct lxb_css_property_white_space_t
    type::lxb_css_white_space_type_t
end

const lxb_css_property_tab_size_t = lxb_css_value_number_length_t

struct lxb_css_property_word_break_t
    type::lxb_css_word_break_type_t
end

struct lxb_css_property_line_break_t
    type::lxb_css_line_break_type_t
end

struct lxb_css_property_hyphens_t
    type::lxb_css_hyphens_type_t
end

struct lxb_css_property_overflow_wrap_t
    type::lxb_css_overflow_wrap_type_t
end

struct lxb_css_property_word_wrap_t
    type::lxb_css_word_wrap_type_t
end

const lxb_css_property_word_spacing_t = lxb_css_value_length_type_t

const lxb_css_property_letter_spacing_t = lxb_css_value_length_type_t

struct lxb_css_property_hanging_punctuation_t
    type_first::lxb_css_hanging_punctuation_type_t
    force_allow::lxb_css_hanging_punctuation_type_t
    last::lxb_css_hanging_punctuation_type_t
end

struct __JL_Ctag_272
    data::NTuple{16,UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_272}, f::Symbol)
    f === :type && return Ptr{lxb_css_font_family_type_t}(x + 0)
    f === :str && return Ptr{lexbor_str_t}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_272, f::Symbol)
    r = Ref{__JL_Ctag_272}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_272}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_272}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct lxb_css_property_family_name
    data::NTuple{40,UInt8}
end

function Base.getproperty(x::Ptr{lxb_css_property_family_name}, f::Symbol)
    f === :generic && return Ptr{Bool}(x + 0)
    f === :u && return Ptr{__JL_Ctag_272}(x + 8)
    f === :next && return Ptr{Ptr{lxb_css_property_family_name_t}}(x + 24)
    f === :prev && return Ptr{Ptr{lxb_css_property_family_name_t}}(x + 32)
    return getfield(x, f)
end

function Base.getproperty(x::lxb_css_property_family_name, f::Symbol)
    r = Ref{lxb_css_property_family_name}(x)
    ptr = Base.unsafe_convert(Ptr{lxb_css_property_family_name}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{lxb_css_property_family_name}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const lxb_css_property_family_name_t = lxb_css_property_family_name

struct lxb_css_property_font_family_t
    first::Ptr{lxb_css_property_family_name_t}
    last::Ptr{lxb_css_property_family_name_t}
    count::Csize_t
end

const lxb_css_property_font_weight_t = lxb_css_value_number_type_t

const lxb_css_property_font_stretch_t = lxb_css_value_percentage_type_t

const lxb_css_property_font_style_t = lxb_css_value_angle_type_t

const lxb_css_property_font_size_t = lxb_css_value_length_percentage_type_t

struct lxb_css_property_float_reference_t
    type::lxb_css_float_reference_type_t
end

struct lxb_css_property_float_t
    type::lxb_css_float_type_t
    length::lxb_css_value_length_type_t
    snap_type::lxb_css_float_type_t
end

struct lxb_css_property_clear_t
    type::lxb_css_clear_type_t
end

const lxb_css_property_float_offset_t = lxb_css_value_length_percentage_t

const lxb_css_property_float_defer_t = lxb_css_value_integer_type_t

struct lxb_css_property_wrap_flow_t
    type::lxb_css_wrap_flow_type_t
end

struct lxb_css_property_wrap_through_t
    type::lxb_css_wrap_through_type_t
end

struct lxb_css_property_flex_direction_t
    type::lxb_css_flex_direction_type_t
end

struct lxb_css_property_flex_wrap_t
    type::lxb_css_flex_wrap_type_t
end

struct lxb_css_property_flex_flow_t
    type_direction::lxb_css_flex_direction_type_t
    wrap::lxb_css_flex_wrap_type_t
end

const lxb_css_property_flex_grow_t = lxb_css_value_number_type_t

const lxb_css_property_flex_shrink_t = lxb_css_value_number_type_t

const lxb_css_property_flex_basis_t = lxb_css_property_width_t

struct lxb_css_property_flex_t
    type::lxb_css_flex_type_t
    grow::lxb_css_property_flex_grow_t
    shrink::lxb_css_property_flex_shrink_t
    basis::lxb_css_property_flex_basis_t
end

struct lxb_css_property_justify_content_t
    type::lxb_css_justify_content_type_t
end

struct lxb_css_property_align_items_t
    type::lxb_css_align_items_type_t
end

struct lxb_css_property_align_self_t
    type::lxb_css_align_self_type_t
end

struct lxb_css_property_align_content_t
    type::lxb_css_align_content_type_t
end

struct lxb_css_property_dominant_baseline_t
    type::lxb_css_dominant_baseline_type_t
end

struct lxb_css_property_baseline_source_t
    type::lxb_css_baseline_source_type_t
end

struct lxb_css_property_alignment_baseline_t
    type::lxb_css_alignment_baseline_type_t
end

const lxb_css_property_baseline_shift_t = lxb_css_value_length_percentage_t

struct lxb_css_property_vertical_align_t
    type::lxb_css_vertical_align_type_t
    alignment::lxb_css_property_alignment_baseline_t
    shift::lxb_css_property_baseline_shift_t
end

const lxb_css_property_line_height_t = lxb_css_value_number_length_percentage_t

const lxb_css_property_z_index_t = lxb_css_value_integer_type_t

struct lxb_css_property_direction_t
    type::lxb_css_direction_type_t
end

struct lxb_css_property_unicode_bidi_t
    type::lxb_css_unicode_bidi_type_t
end

struct lxb_css_property_writing_mode_t
    type::lxb_css_writing_mode_type_t
end

struct lxb_css_property_text_orientation_t
    type::lxb_css_text_orientation_type_t
end

struct lxb_css_property_text_combine_upright_t
    type::lxb_css_text_combine_upright_type_t
    digits::lxb_css_value_integer_t
end

struct lxb_css_property_overflow_x_t
    type::lxb_css_overflow_x_type_t
end

struct lxb_css_property_overflow_y_t
    type::lxb_css_overflow_y_type_t
end

struct lxb_css_property_overflow_block_t
    type::lxb_css_overflow_block_type_t
end

struct lxb_css_property_overflow_inline_t
    type::lxb_css_overflow_inline_type_t
end

struct lxb_css_property_text_overflow_t
    type::lxb_css_text_overflow_type_t
end

struct lxb_css_property_text_decoration_line_t
    type::lxb_css_text_decoration_line_type_t
    underline::lxb_css_text_decoration_line_type_t
    overline::lxb_css_text_decoration_line_type_t
    line_through::lxb_css_text_decoration_line_type_t
    blink::lxb_css_text_decoration_line_type_t
end

struct lxb_css_property_text_decoration_style_t
    type::lxb_css_text_decoration_style_type_t
end

const lxb_css_property_text_decoration_color_t = lxb_css_value_color_t

struct lxb_css_property_text_decoration_t
    line::lxb_css_property_text_decoration_line_t
    style::lxb_css_property_text_decoration_style_t
    color::lxb_css_property_text_decoration_color_t
end

struct lxb_css_syntax_anb_t
    a::Clong
    b::Clong
end

@cenum lxb_css_selector_match_t::UInt32 begin
    LXB_CSS_SELECTOR_MATCH_EQUAL = 0
    LXB_CSS_SELECTOR_MATCH_INCLUDE = 1
    LXB_CSS_SELECTOR_MATCH_DASH = 2
    LXB_CSS_SELECTOR_MATCH_PREFIX = 3
    LXB_CSS_SELECTOR_MATCH_SUFFIX = 4
    LXB_CSS_SELECTOR_MATCH_SUBSTRING = 5
    LXB_CSS_SELECTOR_MATCH__LAST_ENTRY = 6
end

@cenum lxb_css_selector_modifier_t::UInt32 begin
    LXB_CSS_SELECTOR_MODIFIER_UNSET = 0
    LXB_CSS_SELECTOR_MODIFIER_I = 1
    LXB_CSS_SELECTOR_MODIFIER_S = 2
    LXB_CSS_SELECTOR_MODIFIER__LAST_ENTRY = 3
end

struct lxb_css_selector_attribute_t
    match::lxb_css_selector_match_t
    modifier::lxb_css_selector_modifier_t
    value::lexbor_str_t
end

struct lxb_css_selector_pseudo_t
    type::Cuint
    data::Ptr{Cvoid}
end

struct lxb_css_selector_anb_of_t
    anb::lxb_css_syntax_anb_t
    of::Ptr{lxb_css_selector_list_t}
end

@cenum lxb_css_selector_pseudo_class_id_t::UInt32 begin
    LXB_CSS_SELECTOR_PSEUDO_CLASS__UNDEF = 0
    LXB_CSS_SELECTOR_PSEUDO_CLASS_ACTIVE = 1
    LXB_CSS_SELECTOR_PSEUDO_CLASS_ANY_LINK = 2
    LXB_CSS_SELECTOR_PSEUDO_CLASS_BLANK = 3
    LXB_CSS_SELECTOR_PSEUDO_CLASS_CHECKED = 4
    LXB_CSS_SELECTOR_PSEUDO_CLASS_CURRENT = 5
    LXB_CSS_SELECTOR_PSEUDO_CLASS_DEFAULT = 6
    LXB_CSS_SELECTOR_PSEUDO_CLASS_DISABLED = 7
    LXB_CSS_SELECTOR_PSEUDO_CLASS_EMPTY = 8
    LXB_CSS_SELECTOR_PSEUDO_CLASS_ENABLED = 9
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FIRST_CHILD = 10
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FIRST_OF_TYPE = 11
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FOCUS = 12
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FOCUS_VISIBLE = 13
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FOCUS_WITHIN = 14
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FULLSCREEN = 15
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FUTURE = 16
    LXB_CSS_SELECTOR_PSEUDO_CLASS_HOVER = 17
    LXB_CSS_SELECTOR_PSEUDO_CLASS_IN_RANGE = 18
    LXB_CSS_SELECTOR_PSEUDO_CLASS_INDETERMINATE = 19
    LXB_CSS_SELECTOR_PSEUDO_CLASS_INVALID = 20
    LXB_CSS_SELECTOR_PSEUDO_CLASS_LAST_CHILD = 21
    LXB_CSS_SELECTOR_PSEUDO_CLASS_LAST_OF_TYPE = 22
    LXB_CSS_SELECTOR_PSEUDO_CLASS_LINK = 23
    LXB_CSS_SELECTOR_PSEUDO_CLASS_LOCAL_LINK = 24
    LXB_CSS_SELECTOR_PSEUDO_CLASS_ONLY_CHILD = 25
    LXB_CSS_SELECTOR_PSEUDO_CLASS_ONLY_OF_TYPE = 26
    LXB_CSS_SELECTOR_PSEUDO_CLASS_OPTIONAL = 27
    LXB_CSS_SELECTOR_PSEUDO_CLASS_OUT_OF_RANGE = 28
    LXB_CSS_SELECTOR_PSEUDO_CLASS_PAST = 29
    LXB_CSS_SELECTOR_PSEUDO_CLASS_PLACEHOLDER_SHOWN = 30
    LXB_CSS_SELECTOR_PSEUDO_CLASS_READ_ONLY = 31
    LXB_CSS_SELECTOR_PSEUDO_CLASS_READ_WRITE = 32
    LXB_CSS_SELECTOR_PSEUDO_CLASS_REQUIRED = 33
    LXB_CSS_SELECTOR_PSEUDO_CLASS_ROOT = 34
    LXB_CSS_SELECTOR_PSEUDO_CLASS_SCOPE = 35
    LXB_CSS_SELECTOR_PSEUDO_CLASS_TARGET = 36
    LXB_CSS_SELECTOR_PSEUDO_CLASS_TARGET_WITHIN = 37
    LXB_CSS_SELECTOR_PSEUDO_CLASS_USER_INVALID = 38
    LXB_CSS_SELECTOR_PSEUDO_CLASS_VALID = 39
    LXB_CSS_SELECTOR_PSEUDO_CLASS_VISITED = 40
    LXB_CSS_SELECTOR_PSEUDO_CLASS_WARNING = 41
    LXB_CSS_SELECTOR_PSEUDO_CLASS__LAST_ENTRY = 42
end

@cenum lxb_css_selector_pseudo_class_function_id_t::UInt32 begin
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION__UNDEF = 0
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_CURRENT = 1
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_DIR = 2
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_HAS = 3
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_IS = 4
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_LANG = 5
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NOT = 6
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_CHILD = 7
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_COL = 8
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_LAST_CHILD = 9
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_LAST_COL = 10
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_LAST_OF_TYPE = 11
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_OF_TYPE = 12
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_WHERE = 13
    LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION__LAST_ENTRY = 14
end

@cenum lxb_css_selector_pseudo_element_id_t::UInt32 begin
    LXB_CSS_SELECTOR_PSEUDO_ELEMENT__UNDEF = 0
    LXB_CSS_SELECTOR_PSEUDO_ELEMENT_AFTER = 1
    LXB_CSS_SELECTOR_PSEUDO_ELEMENT_BACKDROP = 2
    LXB_CSS_SELECTOR_PSEUDO_ELEMENT_BEFORE = 3
    LXB_CSS_SELECTOR_PSEUDO_ELEMENT_FIRST_LETTER = 4
    LXB_CSS_SELECTOR_PSEUDO_ELEMENT_FIRST_LINE = 5
    LXB_CSS_SELECTOR_PSEUDO_ELEMENT_GRAMMAR_ERROR = 6
    LXB_CSS_SELECTOR_PSEUDO_ELEMENT_INACTIVE_SELECTION = 7
    LXB_CSS_SELECTOR_PSEUDO_ELEMENT_MARKER = 8
    LXB_CSS_SELECTOR_PSEUDO_ELEMENT_PLACEHOLDER = 9
    LXB_CSS_SELECTOR_PSEUDO_ELEMENT_SELECTION = 10
    LXB_CSS_SELECTOR_PSEUDO_ELEMENT_SPELLING_ERROR = 11
    LXB_CSS_SELECTOR_PSEUDO_ELEMENT_TARGET_TEXT = 12
    LXB_CSS_SELECTOR_PSEUDO_ELEMENT__LAST_ENTRY = 13
end

@cenum lxb_css_selector_pseudo_element_function_id_t::UInt32 begin
    LXB_CSS_SELECTOR_PSEUDO_ELEMENT_FUNCTION__UNDEF = 0
    LXB_CSS_SELECTOR_PSEUDO_ELEMENT_FUNCTION__LAST_ENTRY = 1
end

@cenum __JL_Ctag_246::UInt32 begin
    LXB_CSS_SYNTAX_PARSER_ERROR_UNDEF = 0
    LXB_CSS_SYNTAX_PARSER_ERROR_EOINATRU = 1
    LXB_CSS_SYNTAX_PARSER_ERROR_EOINQURU = 2
    LXB_CSS_SYNTAX_PARSER_ERROR_EOINSIBL = 3
    LXB_CSS_SYNTAX_PARSER_ERROR_EOINFU = 4
    LXB_CSS_SYNTAX_PARSER_ERROR_EOBEPARU = 5
    LXB_CSS_SYNTAX_PARSER_ERROR_UNTOAFPARU = 6
    LXB_CSS_SYNTAX_PARSER_ERROR_EOBEPACOVA = 7
    LXB_CSS_SYNTAX_PARSER_ERROR_UNTOAFPACOVA = 8
    LXB_CSS_SYNTAX_PARSER_ERROR_UNTOINDE = 9
end

@cenum lxb_css_syntax_tokenizer_error_id_t::UInt32 begin
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_UNEOF = 0
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_EOINCO = 1
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_EOINST = 2
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_EOINUR = 3
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_QOINUR = 4
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_WRESINUR = 5
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_NEINST = 6
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_BACH = 7
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_BACOPO = 8
end

struct lxb_css_syntax_tokenizer_error_t
    pos::Ptr{lxb_char_t}
    id::lxb_css_syntax_tokenizer_error_id_t
end

struct lxb_css_selectors_pseudo_data_func_t
    name::Ptr{lxb_char_t}
    length::Csize_t
    id::Cuint
    empty::Bool
    combinator::lxb_css_selector_combinator_t
    cb::lxb_css_syntax_cb_function_t
    forgiving::Bool
    comma::Bool
end

struct lxb_css_selectors_pseudo_data_t
    name::Ptr{lxb_char_t}
    length::Csize_t
    id::Cuint
end

function lxb_dom_element_qualified_name(element, len)
    @ccall liblexbor.lxb_dom_element_qualified_name(
        element::Ptr{lxb_dom_element_t},
        len::Ptr{Csize_t},
    )::Ptr{lxb_char_t}
end

function lxb_dom_element_first_attribute_noi(element)
    @ccall liblexbor.lxb_dom_element_first_attribute_noi(
        element::Ptr{lxb_dom_element_t},
    )::Ptr{lxb_dom_attr_t}
end

function lxb_dom_element_next_attribute_noi(attr)
    @ccall liblexbor.lxb_dom_element_next_attribute_noi(
        attr::Ptr{lxb_dom_attr_t},
    )::Ptr{lxb_dom_attr_t}
end

# typedef lxb_status_t ( * lxb_selectors_cb_f ) ( lxb_dom_node_t * node , lxb_css_selector_specificity_t spec , void * ctx )
const lxb_selectors_cb_f = Ptr{Cvoid}

struct lxb_selectors_entry_child
    entry::Ptr{Cvoid} # entry::Ptr{lxb_selectors_entry_t}
    next::Ptr{Cvoid} # next::Ptr{lxb_selectors_entry_child_t}
end

function Base.getproperty(x::lxb_selectors_entry_child, f::Symbol)
    f === :entry && return Ptr{lxb_selectors_entry_t}(getfield(x, f))
    f === :next && return Ptr{lxb_selectors_entry_child_t}(getfield(x, f))
    return getfield(x, f)
end

const lxb_selectors_entry_child_t = lxb_selectors_entry_child

struct lxb_selectors_entry
    id::Csize_t
    selector::Ptr{lxb_css_selector_t}
    node::Ptr{lxb_dom_node_t}
    next::Ptr{Cvoid} # next::Ptr{lxb_selectors_entry_t}
    prev::Ptr{Cvoid} # prev::Ptr{lxb_selectors_entry_t}
    child::Ptr{lxb_selectors_entry_child_t}
end

function Base.getproperty(x::lxb_selectors_entry, f::Symbol)
    f === :next && return Ptr{lxb_selectors_entry_t}(getfield(x, f))
    f === :prev && return Ptr{lxb_selectors_entry_t}(getfield(x, f))
    return getfield(x, f)
end

const lxb_selectors_entry_t = lxb_selectors_entry

@cenum lxb_html_document_opt::UInt32 begin
    LXB_HTML_DOCUMENT_OPT_UNDEF = 0
    LXB_HTML_DOCUMENT_PARSE_WO_COPY = 1
end

function lxb_html_document_destroy(document)
    @ccall liblexbor.lxb_html_document_destroy(
        document::Ptr{lxb_html_document_t},
    )::Ptr{lxb_html_document_t}
end

const lxb_html_tag_category_t = Cint

@cenum lxb_html_tag_category::UInt32 begin
    LXB_HTML_TAG_CATEGORY__UNDEF = 0
    LXB_HTML_TAG_CATEGORY_ORDINARY = 1
    LXB_HTML_TAG_CATEGORY_SPECIAL = 2
    LXB_HTML_TAG_CATEGORY_FORMATTING = 4
    LXB_HTML_TAG_CATEGORY_SCOPE = 8
    LXB_HTML_TAG_CATEGORY_SCOPE_LIST_ITEM = 16
    LXB_HTML_TAG_CATEGORY_SCOPE_BUTTON = 32
    LXB_HTML_TAG_CATEGORY_SCOPE_TABLE = 64
    LXB_HTML_TAG_CATEGORY_SCOPE_SELECT = 128
end

struct lxb_html_tag_fixname_t
    name::Ptr{lxb_char_t}
    len::Cuint
end

@cenum lxb_html_tree_insertion_position_t::UInt32 begin
    LXB_HTML_TREE_INSERTION_POSITION_CHILD = 0
    LXB_HTML_TREE_INSERTION_POSITION_BEFORE = 1
end

struct lxb_html_tree_template_insertion_t
    mode::lxb_html_tree_insertion_mode_f
end

@cenum lxb_html_parser_state_t::UInt32 begin
    LXB_HTML_PARSER_STATE_BEGIN = 0
    LXB_HTML_PARSER_STATE_PROCESS = 1
    LXB_HTML_PARSER_STATE_END = 2
    LXB_HTML_PARSER_STATE_FRAGMENT_PROCESS = 3
    LXB_HTML_PARSER_STATE_ERROR = 4
end

struct lxb_html_parser_t
    tkz::Ptr{lxb_html_tokenizer_t}
    tree::Ptr{lxb_html_tree_t}
    original_tree::Ptr{lxb_html_tree_t}
    root::Ptr{lxb_dom_node_t}
    form::Ptr{lxb_dom_node_t}
    state::lxb_html_parser_state_t
    status::lxb_status_t
    ref_count::Csize_t
end

function lxb_html_parser_create()
    @ccall liblexbor.lxb_html_parser_create()::Ptr{lxb_html_parser_t}
end

function lxb_html_parser_init(parser)
    @ccall liblexbor.lxb_html_parser_init(parser::Ptr{lxb_html_parser_t})::lxb_status_t
end

function lxb_html_parser_destroy(parser)
    @ccall liblexbor.lxb_html_parser_destroy(
        parser::Ptr{lxb_html_parser_t},
    )::Ptr{lxb_html_parser_t}
end

function lxb_html_parse(parser, html, size)
    @ccall liblexbor.lxb_html_parse(
        parser::Ptr{lxb_html_parser_t},
        html::Ptr{lxb_char_t},
        size::Csize_t,
    )::Ptr{lxb_html_document_t}
end

struct lxb_html_encoding_entry_t
    name::Ptr{lxb_char_t}
    _end::Ptr{lxb_char_t}
end

struct lxb_html_encoding_t
    cache::lexbor_array_obj_t
    result::lexbor_array_obj_t
end

const lxb_html_serialize_opt_t = Cint

@cenum lxb_html_serialize_opt::UInt32 begin
    LXB_HTML_SERIALIZE_OPT_UNDEF = 0
    LXB_HTML_SERIALIZE_OPT_SKIP_WS_NODES = 1
    LXB_HTML_SERIALIZE_OPT_SKIP_COMMENT = 2
    LXB_HTML_SERIALIZE_OPT_RAW = 4
    LXB_HTML_SERIALIZE_OPT_WITHOUT_CLOSING = 8
    LXB_HTML_SERIALIZE_OPT_TAG_WITH_NS = 16
    LXB_HTML_SERIALIZE_OPT_WITHOUT_TEXT_INDENT = 32
    LXB_HTML_SERIALIZE_OPT_FULL_DOCTYPE = 64
end

# typedef lxb_status_t ( * lxb_html_serialize_cb_f ) ( const lxb_char_t * data , size_t len , void * ctx )
const lxb_html_serialize_cb_f = Ptr{Cvoid}

struct lxb_html_style_weak
    value::Ptr{Cvoid}
    sp::lxb_css_selector_specificity_t
    next::Ptr{Cvoid} # next::Ptr{lxb_html_style_weak_t}
end

function Base.getproperty(x::lxb_html_style_weak, f::Symbol)
    f === :next && return Ptr{lxb_html_style_weak_t}(getfield(x, f))
    return getfield(x, f)
end

const lxb_html_style_weak_t = lxb_html_style_weak

struct lxb_html_style_node_t
    entry::lexbor_avl_node_t
    weak::Ptr{lxb_html_style_weak_t}
    sp::lxb_css_selector_specificity_t
end

@cenum lxb_html_element_style_opt_t::UInt32 begin
    LXB_HTML_ELEMENT_OPT_UNDEF = 0
end

# typedef lxb_status_t ( * lxb_html_element_style_cb_f ) ( lxb_html_element_t * element , const lxb_css_rule_declaration_t * declr , void * ctx , lxb_css_selector_specificity_t spec , bool is_weak )
const lxb_html_element_style_cb_f = Ptr{Cvoid}

end # module
