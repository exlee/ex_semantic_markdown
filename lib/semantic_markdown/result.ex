defmodule SemanticMarkdown.Result do
  alias SemanticMarkdown.AST

  defp transform_inner_semantic({node_string, attributes, value}, options) do
    content = case(options.earmark_transform_inner) do
                true -> transform_text(value, options)
                _ -> [content: value]
              end
    [{
      String.to_atom(node_string),
      clean_content(content ++ attribute_formatter(attributes))
    }]
  end

  defp clean_content([content: content]), do: content
  defp clean_content(semantic), do: semantic

  defp attribute_formatter(attributes \\ [])
  defp attribute_formatter([]), do: []
  defp attribute_formatter(attributes) do
      for {attribute, value} <- attributes, do: {String.to_atom(attribute), value}
  end

  @spec transform(Earmark.ast(), SemanticMarkdown.option_map(), SemanticMarkdown.result()) :: SemanticMarkdown.result()
  def transform(ast, opts, content) do
    content
    |> Enum.map(&(transform_inner_semantic(&1, opts)))
    |> List.flatten()
    |> Enum.concat(
      ast
      |> Earmark.transform(opts.earmark_transform_options)
      |> then(fn text -> [content: text] end)
    )
end

  @spec transform_text(String.t, SemanticMarkdown.option_map()) :: SemanticMarkdown.result()
  def transform_text(text, opts) do
    ast = Earmark.as_ast!(text, annotations: "%>", footnotes: opts[:footnotes])
    {_, {content, _}} = Earmark.Transform.map_ast_with(ast, {[], opts.tags}, &AST.map_attrs/2, true)

    ast
    |> AST.clean_semantic_tags(opts)
    |> AST.clean_empty_paragraphs(opts)
    |> AST.translate_footnotes(opts)
    |> transform(opts, content)
  end
end
