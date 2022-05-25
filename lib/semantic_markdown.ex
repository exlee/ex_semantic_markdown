defmodule SemanticMarkdown do
  @moduledoc """
  `SemanticMarkdown` is a module for parsing Markdown syntax (using [Earmark](https://github.com/robertdober/earmark_parser)) while retaining semantic structure of the document defined by XML-tags.


  E.g.:

  ```
  iex> SemanticMarkdown.transform(~S\"\"\"
  ...> <title>Lorem ipsum</title>
  ...> Hello world!
  ...> \"\"\", [:title])
  [title: "<p>\\nLorem ipsum</p>\\n", content: "<p>\\nHello world!</p>\\n"]
  ```

  `SemanticMarkdown.transform` takes 3 parameters:
  - `markdown_string` - input markdown (including optionally XML demarking semantic parts)
  - `semantic_tags` - list of atoms of tags to parse
  - `options` - Keyword list such as `t:SemanticMarkdown.Type.options/0`


  It is possible to disable parsing inner tags:
  ```
  iex> options = [earmark_transform_inner: false]
  iex> SemanticMarkdown.transform(~S\"\"\"
  ...> <title>Lorem ipsum</title>
  ...> Hello world!
  ...> \"\"\", [:title], options)
  [title: "Lorem ipsum", content: "<p>\\nHello world!</p>\\n"]
  ```

  As the parsing result is a list same named tags can occur multiple times:
  ```
  iex> options = [earmark_transform_inner: false]
  iex> markdown = \"\"\"
  ...> <color_marker>red</color_marker>
  ...> <color_marker>blue</color_marker>
  ...> <color_marker>green</color_marker>
  ...> <title>Coloring book</title>
  ...> Hello world!
  ...> \"\"\"
  iex> SemanticMarkdown.transform(markdown, [:color_marker, :title], options)
  [
      color_marker: "red",
      color_marker: "blue",
      color_marker: "green",
      title: "Coloring book",
      content: "<p>\\nHello world!</p>\\n"
  ]
  ```

  Content is optional:

  ```
  iex> options = [earmark_transform_inner: false]
  iex> markdown = \"\"\"
  ...> <color_marker>red</color_marker>
  ...> <color_marker>blue</color_marker>
  ...> <color_marker>green</color_marker>
  ...> \"\"\"
  iex> SemanticMarkdown.transform(markdown, [:color_marker, :title], options)
  [
      color_marker: "red",
      color_marker: "blue",
      color_marker: "green"
  ]
  ```

  It's possible to have self-closing tags, however attribute information is missing:
  ```
  iex> options = [earmark_transform_inner: false]
  iex> markdown = \"\"\"
  ...> # Title
  ...> Hello!
  ...> <boing/>
  ...> <boing/>
  ...> <boing/>
  ...> Bye!
  ...> \"\"\"
  iex> SemanticMarkdown.transform(markdown, [:boing], options)
  [
        content: "<h1>\\nTitle</h1>\\n<p>\nHello!</p>\\n",
        boing: true,
        boing: true,
        boing: true,
        content: "<p>\\nBye!</p>\\n"
  ]
  ```


  """

  alias SemanticMarkdown.Type

  @_default_options %{
    footnotes: true,
    footnotes_see: "see footnote",
    footnotes_return: "return to article",
    earmark_transform_inner: true,
    earmark_transform_options: %{},
    content_tag_name: :content,
    merge_content: false
  }

  @spec transform(String.t, [atom(), ...], [Type.options()]) :: Type.result()
  @doc """
  Transforms `markdown_string` into HTML while allowing marking semantic parts of input with configured XML tags.

  """
  def transform(markdown_string, semantic_tags, options \\ []) do
    tags = Enum.map(semantic_tags, &to_string/1)

    opts = @_default_options
    |> Map.merge(Map.new(options))
    |> Map.merge(%{tags: tags})

    SemanticMarkdown.Inner.transform_text(markdown_string, opts)
  end

  @spec transform_from_file!(String.t, [atom(), ...], [Type.option()]) :: Type.result()
  def transform_from_file!(file, semantic_tags, options \\ []) do
    File.read!(file)
    |> transform(semantic_tags, options)
  end
end
