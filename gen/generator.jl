import Pkg
import Pkg.Artifacts
import Clang.Generators
import Clang.Generators.JLLEnvs
import lexbor_jll
import JuliaFormatter

cd(@__DIR__) do
    include_dir = normpath(joinpath(lexbor_jll.artifact_dir, "include"))
    @assert isdir(include_dir)

    options = Generators.load_options(joinpath(@__DIR__, "generator.toml"))

    args = Generators.get_default_args()
    push!(args, "-I$include_dir")

    header_files = [joinpath(include_dir, "lexbor", "html", "html.h")]

    ctx = Generators.create_context(header_files, args, options)

    Generators.build!(ctx, Generators.BUILDSTAGE_NO_PRINTING)

    allowed_functions = Set([
        :lxb_html_document_destroy,
        :lxb_html_tokenizer_tags_noi,
        :lxb_tag_name_by_id_noi,
        :lxb_html_tokenizer_destroy,
        :lxb_html_tokenizer_create,
        :lxb_html_tokenizer_init,
        :lxb_html_tokenizer_callback_token_done_set_noi,
        :lxb_html_tokenizer_begin,
        :lxb_html_tokenizer_chunk,
        :lxb_html_tokenizer_end,
        :lxb_html_parser_create,
        :lxb_html_parser_init,
        :lxb_html_parser_destroy,
        :lxb_html_parse,
        :lxb_html_document_destroy,
        :lxb_dom_node_text_content,
        :lxb_dom_node_first_child_noi,
        :lxb_dom_node_next_noi,
        :lxb_dom_node_prev_noi,
        :lxb_dom_element_qualified_name,
        :lxb_dom_element_first_attribute_noi,
        :lxb_dom_attr_value_noi,
        :lxb_dom_attr_qualified_name,
        :lxb_dom_element_next_attribute_noi,
    ])

    function rewrite!(e::Expr)
        if Meta.isexpr(e, :function)
            name = e.args[1].args[1]
            if name === :lxb_css_syntax_token
                e.args[1].args[2] = :($(e.args[1].args[2])::Ptr{lxb_css_syntax_tokenizer_t})
            end
            if isa(name, Symbol) && name ∉ allowed_functions
                e.head = :(=)
                e.args = [:_, "skip-this-code"]
            end
        end
        return e
    end

    function rewrite!(dag::Generators.ExprDAG)
        for node in Generators.get_nodes(dag)
            for expr in Generators.get_exprs(node)
                rewrite!(expr)
            end
        end
    end

    rewrite!(ctx.dag)

    Generators.build!(ctx, Generators.BUILDSTAGE_PRINTING_ONLY)

    generated_file = joinpath(@__DIR__, "..", "src", "liblexbor_api.jl")
    content = read(generated_file, String)
    content = replace(content, "_ = \"skip-this-code\"" => "")
    write(generated_file, content)

    JuliaFormatter.format_file(generated_file)
end
