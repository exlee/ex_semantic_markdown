# SemanticMarkdown

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `semantic_markdown` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:semantic_markdown, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/semantic_markdown>.


## Rationale

### Footnotes

At the time of writing this library `Earmark` hardcodes `see footnotes` and `return to article` when parsing them.

`SemanticMarkdown` provides options to replace those during parse allowing to use non-English titles (e.g. with `gettext`).


## Known issues

- [ ] it should be possible to have inner transforms on tag-by-tag or even node-by-node basis
