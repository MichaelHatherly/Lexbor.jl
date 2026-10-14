```@meta
CurrentModule = Lexbor
```

# Lexbor.jl

This package provides a Julia interface to the
[lexbor](https://github.com/lexbor/lexbor) HTML parsing library. `Lexbor.jl`
integrates with `AbstractTrees.jl` to provide an interface for traversing the
HTML tree.

The package parses HTML and queries it with CSS selectors. It also navigates,
inspects, and serializes the resulting DOM. New nodes and parsed fragments can
be attached to edit it.

## Usage

The package exports its parsing, querying, and node inspection functions. The
navigation, serialization, and mutation functions are public but unexported.
Prefer qualified identifiers for both.

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
Lexbor.first_child(div)
Lexbor.last_child(div)
```

The accessors are [`parent_node`](@ref), [`next_sibling`](@ref),
[`prev_sibling`](@ref), [`first_child`](@ref), and [`last_child`](@ref). They
step through every kind of node, including whitespace text and comments.
[`next_element`](@ref), [`prev_element`](@ref), [`first_element`](@ref), and
[`last_element`](@ref) skip to the nearest element instead.

```@repl usage
spaced = Lexbor.Document("<ul> <li>a</li> <!--x--> <li>b</li> </ul>")
items = only(Lexbor.query(spaced, "ul"))
Lexbor.first_child(items)
Lexbor.first_element(items)
Lexbor.next_element(Lexbor.first_element(items))
```

[`closest`](@ref) walks up from a node, itself included, to the first element
matching a CSS selector.

```@repl usage
Lexbor.closest(link, "div.callout")
Lexbor.closest(link, "table")
```

[`Node`](@ref) implements the `AbstractTrees` parent interface, so generic tree
utilities work on it directly: `AbstractTrees.getroot`, `AbstractTrees.isroot`,
and `AbstractTrees.isdescendant`. `parent_node` backs `AbstractTrees.parent`, and
the sibling accessors back `nextsibling` and `prevsibling`.

### Reading text

[`text_content`](@ref) returns the text of a node and all its descendants,
following the DOM `textContent` property. [`text`](@ref) reads a single text node
and returns `nothing` for elements.

```@repl usage
Lexbor.text_content(div)
Lexbor.text(div)
```

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
Lexbor.document_element(page)
```

[`set_title!`](@ref) changes the title, adding a `<title>` element when the
document has none.

```@repl usage
Lexbor.set_title!(page, "Renamed")
Lexbor.title(page)
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

[`replace_node!`](@ref) puts one node in another's place.
[`set_inner_html!`](@ref) replaces an element's children with parsed HTML.

```@repl usage
Lexbor.append_child!(container, para)
Lexbor.replace_node!(para, Lexbor.create_element(mut, "hr"))
Lexbor.set_inner_html!(container, "<em>new</em> content")
Lexbor.outer_html(container)
```

### Copying nodes

[`clone_node`](@ref) copies a node within its document. [`import_node`](@ref)
copies a node from any document into another, where it can then be inserted.
Both copy descendants unless `deep = false`.

```@repl usage
duplicate = Lexbor.clone_node(container)
other = Lexbor.Document("<main></main>")
moved = Lexbor.import_node(other, container)
Lexbor.append_child!(only(Lexbor.query(other, "main")), moved)
Lexbor.outer_html(other)
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
