defmodule SemanticMarkdown.AST do
  @moduledoc """
  `SemanticMarkdown.AST` module contains utilities
  for transforming `Earmark`'s AST.
  """
  alias Earmark.Transform
  alias SemanticMarkdown.Type

  @temporary_semantic_tag :"ex-semantic-markdown-content"
  @tt @temporary_semantic_tag

  defguard is_temporary_tag(n) when n == @tt

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

  @spec group_reducer({atom(), Type.ast}, Type.ast) :: [{atom(), Type.ast}]
  def group_reducer({@tt, value}, [{@tt, acc_value} | tail]) do
    [{@tt, acc_value ++ value} | tail]
  end
  def group_reducer(node, acc), do: [node | acc]

  @spec ast_parse(Type.ast_tuple, Type.options_map) :: {atom(), Type.ast_tuple | [Type.ast_tuple]}
  def ast_parse({node_name, _, _, _meta} = node, options) do
    if node_name in options.tags do
      {String.to_atom(node_name), node}
    else
      {@tt, [node]}
    end
  end

  @spec preparse(Type.ast, Type.options_map) :: [{atom(), Type.ast}, ...]
  def preparse(ast, options) do
    ast
    |> Enum.map(&(ast_parse(&1, options)))
    |> Enum.reduce([], &group_reducer/2)
    |> Enum.reverse
  end

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
end
