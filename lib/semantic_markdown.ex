defmodule SemanticMarkdown do
  @moduledoc """
  `SemanticMarkdown` is a module for parsing Markdown syntax (using [Earmark](https://github.com/robertdober/earmark_parser)) while retaining semantic structure of the document defined by XML-tags.


  E.g.:

  ```
  iex> SemanticMarkdown.transform(~S\"\"\"
  ...> <title>Lorem ipsum</title>
  ...> Hello world!
  ...> \"\"\", [:title])
  [title: "<p>Lorem ipsum</p>", content: "<p>Hello world!</p>"]
  ```

  `SemanticMarkdown.transform` takes 3 parameters:
  - `markdown_string` - input markdown (including optionally XML demarking semantic parts)
  - `semantic_tags` - list of atoms of tags to parse
  - `options` - Keyword list such as `t:SemanticMarkdown.Type.options/0`


  It is possible to disable parsing inner tags:
  ```
  iex> options = [earmark_inner_transform: false]
  iex> SemanticMarkdown.transform(~S\"\"\"
  ...> <title>Lorem ipsum</title>
  ...> Hello world!
  ...> \"\"\", [:title], options)
  [title: "Lorem ipsum", content: "<p>Hello world!</p>"]
  ```

  As the parsing result is a list same named tags can occur multiple times:
  ```
  iex> options = [earmark_inner_transform: false]
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
      content: "<p>Hello world!</p>"
  ]
  ```

  Content is optional:

  ```
  iex> options = [earmark_inner_transform: false]
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
  iex> options = [earmark_inner_transform: false]
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
        content: "<h1>Title</h1><p>Hello!</p>",
        boing: true,
        boing: true,
        boing: true,
        content: "<p>Bye!</p>"
  ]
  ```

  """

  alias SemanticMarkdown.Type

  @_default_options %{
    footnotes: true,
    footnotes_see: "see footnote",
    footnotes_return: "return to article",
    clean_newlines: true,
    earmark_inner_transform: true,
    earmark_transform_options: %{},
    content_tag_name: "content",
    merge_content: false
  }

  @doc """
  Transforms `markdown_string` into keyworded list containing separated parts by semantic tag
  """
  @spec transform(String.t(), [atom(), ...], [Type.options()]) :: Type.result()
  def transform(markdown_string, semantic_tags, options \\ []) do
    tags = Enum.map(semantic_tags, &to_string/1)

    opts =
      @_default_options
      |> Map.merge(Map.new(options))
      |> Map.merge(%{tags: tags})

    SemanticMarkdown.Inner.transform_text(markdown_string, opts)
  end

  @doc """
  Helper function that takes a file path string, list of tags and options
  and returns keyword list of parsed content.
  """
  @spec transform_from_file!(String.t(), [atom(), ...], [Type.option()]) :: Type.result()
  def transform_from_file!(file, semantic_tags, options \\ []) do
    File.read!(file)
    |> transform(semantic_tags, options)
  end
end
