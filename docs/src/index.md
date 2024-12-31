# Lexbor.jl

This package provides a Julia interface to the
[lexbor](https://github.com/lexbor/lexbor) HTML parsing library. `Lexbor.jl`
integrates with `AbstractTrees.jl` to provide an interface for traversing the
HTML tree.

Currently the only exposed parts of the library are HTML parsing and DOM
querying.

## Usage

The package `export`s it's public interface, but prefer using qualified
identifiers rather than `using`.

```@repl usage
import Lexbor
```

### Parsing HTML

Create a new DOM object using the `Document` constructor.

```@repl usage
doc = Lexbor.Document("<div class='callout'><a href='#'>Link</a></div>")
```

Or you can parse a file with `Base.open`:

```@repl usage
doc = open(Lexbor.Document, "file.html")
```

### Querying documents

Use `query` to search for nodes within the document that match the provided CSS
selector.

```@repl usage
links = Lexbor.query(doc, "a")
```

```@repl usage
callouts = Lexbor.query(doc, "div.callout")
```

[`query`](@ref) also supports passing a function as the first argument that
will be called on each matching [`Node`](@ref) that is found. Using this
method avoids allocating a vector and iterating over the results twice if they
don't need to be stored.

```@repl usage
Lexbor.query(doc, "a") do link
    @show Lexbor.attributes(link)
end
```

### Iteration

You can use any `AbstractTrees` iterators to traverse the document contents.

```@repl usage
import AbstractTrees

for node in AbstractTrees.PreOrderDFS(Lexbor.Node(doc))
    if Lexbor.is_text(node)
        @show Lexbor.text(node)
    end
end
```

This uses [`is_text`](@ref) to check whether the current `node` is a plain text
[`Node`](@ref) and then displays the text content of it using [`text`](@ref).
Note that newlines and other whitespace is preserved by lexbor's parsing.

Other predicates and accessors available are:

- [`is_element`](@ref)
- [`is_comment`](@ref)
- [`tag`](@ref)
- [`comment`](@ref)

### Matching `Node`s

[`Matcher`](@ref) allows for testing a [`Node`](@ref) to determine whether it
matches the given CSS selector.

```@repl usage
matcher = Lexbor.Matcher("div.callout")
for node in AbstractTrees.PreOrderDFS(Lexbor.Node(doc))
    if matcher(node)
        @show node
    end
end
```

As with [`query`](@ref) you can pass a function as the first argument to a
[`Matcher`](@ref) object in which case it will get called when the
[`Node`](@ref) matches and will return `nothing` instead of `true`/`false`.

```@repl usage
for node in AbstractTrees.PreOrderDFS(Lexbor.Node(doc))
    matcher(node) do matched
        @show matched
    end
end
```

## API

```@autodocs
Modules = [Lexbor]
```
