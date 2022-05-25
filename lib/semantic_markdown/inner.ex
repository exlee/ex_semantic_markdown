defmodule SemanticMarkdown.Inner do
  @moduledoc """
  `SemanticMarkdown.Inner` Contains inner implementation of Markdown parser, including `transform` that allows to work on the `Earmark`'s AST tree directly and `transform_text` that takes processed `SemanticMarkdown.Type.options_map()`.
  """
  alias SemanticMarkdown.{AST, Type}

  @spec transform_inner_semantic(Type.semantic_inner_ast, Type.options_map) :: Type.result
  defp transform_inner_semantic({node_name, attributes, value, meta}, %{earmark_transform_inner: true} = options) do

    [
      attributes: attributes,
      content: transform_text_inner(value, options)
    ]
  end

  defp transform_inner_semantic({node_name, attributes, value, meta}, _) do
    [
      attributes: attributes,
      content: value
    ]
  end

  @spec clean_content([Keyword.t, ...]) :: [Keyword.t, ...] | String.t
  defp clean_content([attributes: [], content: []]), do: true
  defp clean_content([attributes: [], content: [value]]), do: value
  defp clean_content([attributes: [], content: value]), do: value
  defp clean_content([content: value]), do: value
  defp clean_content(v), do: v

  @spec attribute_formatter([{String.t, any}]) :: [Keyword.t]
  defp attribute_formatter(attributes \\ [])
  defp attribute_formatter([]), do: []
  defp attribute_formatter(attributes) do
      for {attribute, value} <- attributes, do: {String.to_atom(attribute), value}
  end

  def transform_node({:'ex-semantic-markdown-content', value}, options) do
    {
      options.content_tag_name,
      Earmark.transform(value, options.earmark_transform_options)
    }
  end
  def transform_node({key, value}, options) do
    {
      key,
      clean_content(transform_inner_semantic(value, options))
    }
  end

  @spec transform(Type.ast, Type.options_map) :: Type.result
  def transform(ast, opts) do
    ast
    |> Enum.map(fn n -> transform_node(n, opts) end)
    # |> Enum.concat(
    #   ast
    #   |> Earmark.transform(opts.earmark_transform_options)
    #   |> then(fn text -> [content: text] end)
    # )
  end

  def merge_content(content, %{merge_content: true, content_tag_name: tag} ) do
    merged = Enum.reduce(content, "", fn
      ({^tag, text}, acc) -> acc <> "\n" <> text
      (node, acc) -> acc
    end)
    Enum.filter(content, fn {k, v} -> k != tag end) ++ [content: merged]
  end
  def merge_content(content, options), do: content

  def transform_text_inner(text, opts) do
    ast = Earmark.as_ast!(text, annotations: "%>", footnotes: opts[:footnotes])
    ast
    |> AST.translate_footnotes(opts)
    |> AST.preparse(opts)
    |> transform(opts)
    |> clean_content
  end

  @spec transform_text(String.t, Type.options_map) :: Type.result
  def transform_text(text, opts) do
    transform_text_inner(text, opts)
    |> merge_content(opts)
  end
end
