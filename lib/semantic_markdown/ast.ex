defmodule SemanticMarkdown.AST do
  @moduledoc """
  `SemanticMarkdown.AST` module contains utilities
  for transforming `Earmark`'s AST.
  """
  alias Earmark.Transform
  alias SemanticMarkdown.Type

  @temporary_generic_content_tag :'ex-semantic-markdown-content'

  @spec map_attrs(Type.ast_tuple, {[{String.t, String.t}], [String.t, ...]}) :: {Type.ast_tuple, {[{String.t, String.t}], [String.t, ...]}}
  def map_attrs({node_name, attrs, values, _} = n, {list, keys}) do
    if node_name in keys do
      case values do
        [value] -> {n, {list ++ [{node_name, attrs, value}], keys}}
        _ -> {n, {list ++ [{node_name, attrs, values}], keys}}
      end
    else
      case values do
        [value] -> {n, {list ++ [{"exsm-content", attrs, value}], keys}}
        _ -> {n, {list ++ [{"exsm-content", attrs, values}], keys}}
      end
    end
  end


  @spec make_semantic_cleaner([String.t, ...]) :: (Type.ast_tuple -> {:replace, String.t} | Type.ast_tuple)
  def make_semantic_cleaner(keys) do
    fn {attr, _, _, _} = node ->
      if attr in keys do
        {:replace, ""}
      else
        node
      end
    end
  end

  @tt @temporary_generic_content_tag
  def group_reducer({@tt, value}, [{@tt, acc_value} | tail]) do
    [{@tt, acc_value ++ value} | tail]
  end
  def group_reducer(node, acc), do: [node | acc]

  def ast_parse({node_name, _, _, _meta} = node, options) do
    if node_name in options.tags do
      {String.to_atom(node_name), node}
    else
      {@temporary_generic_content_tag, [node]}
    end
  end

  def update_content_name(ast, options) do
    ast
    |> Enum.map(&(update_content_name(&1, options.content_tag_name)))
  end
  def update_content_name({@temporary_generic_content_tag, value}, final_name) do
    {final_name, value}
  end

  def update_content_name(node, _), do: node

  def preparse(ast, options) do
    ast
    |> Enum.map(&(ast_parse(&1, options)))
    |> Enum.reduce([], &group_reducer/2)
    |> Enum.reverse
  end


  @spec map_clean_empty_paragraphs(Type.ast_tuple) :: {:replace, String.t} | Type.ast_tuple
  def map_clean_empty_paragraphs(node)
  def map_clean_empty_paragraphs({"p", _, [""], _}) do
    {:replace, ""}
  end
  def map_clean_empty_paragraphs(n), do: n

  @spec replace_attr(Type.ast_tuple, String.t, String.t) :: Type.ast_tuple
  def replace_attr({element, attrs, value, meta}, key, new_text) do
    List.keyreplace(attrs, key, 0, {key, new_text})
    |> then(fn attrs -> {element, attrs, value, meta} end)
  end

  @spec make_translate_footnotes_mapper(Type.options_map) :: (
    Type.ast_tuple -> Type.ast_tuple
  )
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

  @spec translate_footnotes(Type.ast, Type.options_map) :: Type.ast
  def translate_footnotes(ast, opts) do
    Transform.map_ast(ast, make_translate_footnotes_mapper(opts), true)
  end

  @spec clean_semantic_tags(Type.ast, Type.options_map) :: Type.ast
  def clean_semantic_tags(ast, %{tags: tags, clean_semantic_tags: true}) do
    Transform.map_ast(ast, make_semantic_cleaner(tags), true)
  end
  def clean_semantic_tags(ast, _), do: ast

  @spec clean_empty_paragraphs(Type.ast, Type.options_map) :: Type.ast
  def clean_empty_paragraphs(ast, %{clean_empty_paragraphs: true}) do
    Transform.map_ast(ast, &map_clean_empty_paragraphs/1, true)
  end
  def clean_empty_paragraphs(ast, _), do: ast
end
