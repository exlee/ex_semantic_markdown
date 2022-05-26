# SemanticMarkdown

## Description

`SemanticMarkdown` is a library that allows marking parts of the Markdown document with XML tags.
Those are extracted and provided in Keyword-list form along with the non marked format.

E.g.:

```markdown
<author>Alexander "exlee" Kaminski</author>
<date>2022-02-02</date>
<language>en_US</language>

# Hello World!

Every document has to start somewhere?!

<hint>It's possible to extend from World to Universe at some point</hint>

<mobile_content>
As _content_ on this *page* is very intensive you will not be able to see the images!
</mobile_content>

<update>2022-02-03 : Added hint</update>
<update>2022-02-04 : Set tags</update>
```

... is transformed into friendly keyword list:
```elixir
[
  author: ...,
  date: ...,
  language: ...,
  content: ...,
  mobile_content: ...,
  update: ...,
  update: ...
]
```

Such list could be then used for conditional rendering or all kinds of rendering transformation using marked parts/attributes.

Solution space:
- Have a local markdown-based CMS system
- Conditional content loading depending on various conditions, like locale or browser configuration (without DB)
- Data points embedding for interactive components
- Assymetrical documents (e.g. flashcards)


## Installation

`SemanticMarkdown` can be installed by adding `semantic_markdown` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:semantic_markdown, "~> 0.1.0"}
  ]
end
```

Documentation can be found at <https://hexdocs.pm/semantic_markdown>.


## Rationale

Markdown is a great format for short and longer forms. However it's somewhat limited when it comes
to creating structured content.  The usual solutions is to use either CMS system or directly
database in order to feed content. Database modelling takes time and might be an overkill for small solutions.

Also - Markdown is VERY good for writing content, so if the solution is small, text-driven one can use
Markdown instead of trying to hammer-in back office system so that the content can be provided.

### Database

Same semantic information can be obtained by using database. For small solutions modelling database
or even setting it up can be overkill over having flat local files. Semantic marking allows for
example loading markdown into local database (like SQLite3) for faster reads and incrementally
extending model as needed.

### Footnotes

At the time of writing this library `Earmark` hard codes `see footnotes` and `return to article` when
parsing them.  `SemanticMarkdown` provides options to replace those during parse allowing to use
non-English titles (e.g. with `gettext`), which was another motivation and the actual

### TL;DR;

I wanted to have simple CMS system for a content generation, and couldn't find one, so made my own ;)

## Alternative solutions

### Front-matter

Some Markdown parsing solutions are using "header" parts in order to provide data with semantic value, e.g.:

```
date: 2022-02-02
language: en_US
author: Anonymous Writer

-----

# Title of the document
(...)

```

Where front-matter can be any format (XML, TOML, YAML etc.).

Such approach works well when provided data can be embedded in such data file.
It doesn't allow marking parts of document and it's usually developer's responsibility to make sure that document is split in proper manner.

### XML Parsing

XML parsing (with library such as [SweetXml](https://github.com/kbrw/sweet_xml)) would _probably_ be preferable.
```
<xml>
  <title> ... </title>
  <content>
    ...
  </content>
  <sources>
    ...
  </sources>
</xml>
```

Since not only that would provide semantic tagging and formatting but also allow for hardening data with name spaces.
However, if one decides to use it, they're on their own to implement Markdown parsing for specific nodes.

### Markdown classes

Instead of toying with semantic tagging one could use IAL extensions (see [Earmark's](https://hexdocs.pm/earmark_parser/EarmarkParser.html#module-adding-attributes-with-the-ial-extension)) and then use other methods of hiding content (like CSS/JS).

### Document splitting

It it's also possible to split the `.md` files into multiple ones using schema like, but if there are a lot of information with semantic meaning such split would be very cumbersome to uphold.


## Missing features / known issues

- [ ] it should be possible to have inner transforms on tag-by-tag or even node-by-node basis
- [ ] footnotes need to be in the same semantic node making them somewhat useless
- [ ] since parsing is done using `Earmark` it shares some caveats (like [HTML Limitation](https://hexdocs.pm/earmark_parser/EarmarkParser.html#module-limitations))
- [ ] no performance tests were done, but most likely it's not very fast so the input files should be pre-processed and cached
- [ ] it'd be nice to have tag transformers provided in form of `(text) -> any` so that output can be "smarter"
- [ ] nested semantic tags are not supported (this probably would require switching parser entirely)


### Next

1. More tests, especially with more complex documents
2. Configurable transformers for tags
3. Per-tag inner-parsing
