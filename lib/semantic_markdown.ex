defmodule SemanticMarkdown do
  @moduledoc """
  `SemanticMarkdown` is a module for parsing Markdown syntax (using (Earmark)[https://github.com/robertdober/earmark_parser]) while retaining semantic structure of the document defined by XML-tags.
  """

  @_default_options %{
    footnotes: true,
    footnotes_see: "see footnote",
    footnotes_return: "return to article",
    clean_semantic_tags: true,
    clean_empty_paragraphs: true,
    earmark_transform_inner: true,
    earmark_transform_options: []
  }

  @type option() ::
  {:footnotes, boolean()}
  | {:footnotes_see, String.t}
  | {:footnotes_return, String.t}
  | {:clean_semantic_tags, boolean()}
  | {:clean_empty_paragraphs, boolean()}
  | {:earmark_transform_inner, boolean()}
  | {:earmark_transform_options, Keyword.t()}

  @type option_map() :: %{
    footnotes: boolean(),
    footnotes_see: String.t,
    footnotes_return: String.t,
    clean_semantic_tags: boolean(),
    clean_empty_paragraphs: boolean(),
    earmark_transform_inner: boolean(),
    earmark_transform_options: [any],
    tags: [atom()]
  }

  @type semantic_tag() :: String.t | [result(), ...]
  @type result() :: [content: String.t] | [{atom(), semantic_tag()}, ...]

  @spec transform(String.t, [atom(), ...], [option()]) :: result()
  def transform(markdown_string, semantic_tags, options \\ []) do
    tags = Enum.map(semantic_tags, &to_string/1)

    opts = @_default_options
    |> Map.merge(Map.new(options))
    |> Map.merge(%{tags: tags})

    SemanticMarkdown.Result.transform_text(markdown_string, opts)
  end

  @spec transform_from_file!(String.t, [atom(), ...], [option()]) :: result()
  def transform_from_file!(file, semantic_tags, options \\ []) do
    File.read!(file)
    |> transform(semantic_tags, options)
  end
end
