# Lexbor.jl

This package provides a Julia interface to the
[lexbor](https://github.com/lexbor/lexbor) HTML parsing library. `Lexbor.jl`
integrates with `AbstractTrees.jl` to provide an interface for traversing the
HTML tree.

The exposed parts of the library are HTML parsing, DOM querying, node
navigation, attribute access, HTML serialization, tree mutation, and fragment
parsing.

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

### Navigating nodes

Move around the tree relative to a given [`Node`](@ref). Each accessor returns a
[`Node`](@ref) or `nothing` when there is no such node.

```@repl usage
div = only(Lexbor.query(doc, "div.callout"))
link = only(Lexbor.query(doc, "a"))
Lexbor.parent_node(link)
Lexbor.next_sibling(link)
Lexbor.prev_sibling(link)
Lexbor.last_child(div)
```

The accessors are [`parent_node`](@ref), [`next_sibling`](@ref),
[`prev_sibling`](@ref), and [`last_child`](@ref).

### Attribute access

Read a single attribute of an element with [`attribute`](@ref). It returns the
value as a `String`, or `nothing` when the attribute is absent or present but
valueless.

```@repl usage
Lexbor.attribute(link, "href")
Lexbor.attribute(link, "target")
```

[`has_attribute`](@ref) tells an absent attribute apart from a valueless one.

```@repl usage
Lexbor.has_attribute(link, "href")
Lexbor.has_attribute(link, "target")
```

Use [`attributes`](@ref) to read every attribute of an element as a `Dict`.

```@repl usage
Lexbor.attributes(link)
```

### Serializing documents

Serialize a [`Node`](@ref) or [`Document`](@ref) back to HTML.
[`outer_html`](@ref) includes the node itself; [`inner_html`](@ref) emits its
descendants only.

```@repl usage
Lexbor.outer_html(div)
Lexbor.inner_html(div)
Lexbor.outer_html(doc)
```

### Document accessors

Reach the standard parts of a parsed document with [`title`](@ref),
[`head`](@ref), and [`body`](@ref).

```@repl usage
page = Lexbor.Document("<html><head><title>Example</title></head><body><p>Hi</p></body></html>")
Lexbor.title(page)
Lexbor.head(page)
Lexbor.body(page)
```

### Modifying documents

Build up a document by creating nodes and attaching them.
[`create_element`](@ref), [`create_text`](@ref), and [`create_comment`](@ref) make
detached nodes; [`append_child!`](@ref), [`insert_before!`](@ref), and
[`insert_after!`](@ref) attach them.

```@repl usage
mut = Lexbor.Document("<div id='content'></div>")
container = only(Lexbor.query(mut, "#content"))
para = Lexbor.create_element(mut, "p")
Lexbor.append_child!(container, para)
Lexbor.append_child!(para, Lexbor.create_text(mut, "Hello"))
Lexbor.set_attribute!(para, "class", "greeting")
Lexbor.outer_html(container)
```

[`set_text!`](@ref) replaces an element's content, [`remove_attribute!`](@ref)
drops an attribute, and [`remove!`](@ref) unlinks a node from its parent.

```@repl usage
Lexbor.set_text!(para, "Goodbye")
Lexbor.remove_attribute!(para, "class")
Lexbor.outer_html(container)
Lexbor.remove!(para)
Lexbor.outer_html(container)
```

### Parsing fragments

[`fragment`](@ref) parses an HTML string into detached nodes ready to attach with
the same insertion functions.

```@repl usage
list = Lexbor.Document("<ul></ul>")
ul = only(Lexbor.query(list, "ul"))
items = Lexbor.fragment(list, "<li>one</li><li>two</li>"; context = ul)
foreach(item -> Lexbor.append_child!(ul, item), items)
Lexbor.outer_html(ul)
```

Parsing depends on the `context` element: a `<td>` is kept under a table row
context but reduced to bare text under `<body>`.

```@repl usage
table = Lexbor.Document("<table><tr></tr></table>")
row = only(Lexbor.query(table, "tr"))
cell = only(Lexbor.fragment(table, "<td>cell</td>"; context = row))
Lexbor.outer_html(cell)
```

## API

```@autodocs
Modules = [Lexbor]
```
