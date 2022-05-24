defmodule SemanticMarkdown.AST do
  alias Earmark.Transform

  @spec map_attrs({any, any, any, any}, {any, any}) :: {{any, any, any, any}, {any, any}}
  def map_attrs({node_name, attrs, values, _} = n, {list, keys}) do
    if node_name in keys do
      case values do
        [value] -> { n, {list ++ [{node_name, attrs, value}], keys}}
        _ -> { n, { list ++ [{node_name, values}], keys }}
      end
    else
      { n, {list, keys} }
    end
  end

  def make_semantic_cleaner(keys) do
    fn {attr, _, _, _} = node ->
      if attr in keys do
        {:replace, ""}
      else
        node
      end
    end
  end

  def map_clean_empty_paragraphs(node)
  def map_clean_empty_paragraphs({"p", _, [""], _}) do
    {:replace, ""}
  end
  def map_clean_empty_paragraphs(n), do: n

  defp replace_attr({element, attrs, value, meta}, key, new_text) do
    List.keyreplace(attrs, key, 0, {key, new_text})
    |> then(fn attrs -> {element, attrs, value, meta} end)
  end

  def make_translate_footnotes_mapper(opts) do
    fn node ->
      case Earmark.AstTools.find_att_in_node(node, "title") do
        "see footnote" ->
          replace_attr(node, "title", opts[:footnotes_see])
        "return to article" ->
          replace_attr(node, "title", opts[:footnotes_return])
        _ -> node
      end
    end
  end

  def translate_footnotes(ast, opts) do
    Transform.map_ast(ast, make_translate_footnotes_mapper(opts), true)
  end

  def clean_semantic_tags(ast, %{tags: tags, clean_semantic_tags: true}) do
    Transform.map_ast(ast, make_semantic_cleaner(tags), true)
  end
  def clean_semantic_tags(ast, _), do: ast

  def clean_empty_paragraphs(ast, %{clean_empty_paragraphs: true}) do
    Transform.map_ast(ast, &map_clean_empty_paragraphs/1, true)
  end
  def clean_empty_paragraphs(ast, _), do: ast
end
