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

  @spec group_reducer({atom(), Type.ast()}, Type.ast()) :: [{atom(), Type.ast()}]
  defp group_reducer({@tt, value}, [{@tt, acc_value} | tail]) do
    [{@tt, acc_value ++ value} | tail]
  end

  defp group_reducer(node, acc), do: [node | acc]

  @spec ast_parse(Type.ast_tuple(), Type.options_map()) ::
          {atom(), Type.ast_tuple() | [Type.ast_tuple()]}
  defp ast_parse({node_name, _, _, _meta} = node, options) do
    if node_name in options.tags do
      {String.to_atom(node_name), node}
    else
      {@tt, [node]}
    end
  end

  @doc """
  Transform AST tree so that non-tagged nodes get a node by themselves (and sibling nodes are combined into one)
  """
  @spec preparse(Type.ast(), Type.options_map()) :: [{atom(), Type.ast()}, ...]
  def preparse(ast, options) do
    ast
    |> Enum.map(&ast_parse(&1, options))
    |> Enum.reduce([], &group_reducer/2)
    |> Enum.reverse()
  end

  @doc """
  Helper function, replace the value of given attribute with the other one
  """
  @spec replace_attr(Type.ast_tuple(), String.t(), String.t()) :: Type.ast_tuple()
  def replace_attr(ast_node, attribute_name, new_value)

  def replace_attr({element, attrs, value, meta}, key, new_text) do
    List.keyreplace(attrs, key, 0, {key, new_text})
    |> then(fn attrs -> {element, attrs, value, meta} end)
  end

  @spec make_translate_footnotes_mapper(Type.options_map()) ::
          (Type.ast_tuple() -> Type.ast_tuple())
  defp make_translate_footnotes_mapper(opts) do
    fn node ->
      case Earmark.AstTools.find_att_in_node(node, "title") do
        "see footnote" ->
          replace_attr(node, "title", opts[:footnotes_see])

        "return to article" ->
          replace_attr(node, "title", opts[:footnotes_return])

        _ ->
          node
      end
    end
  end

  @doc """
  Replace `Earmark`'s footnotes with the ones provided in configuration
  """
  @spec translate_footnotes(Type.ast(), Type.options_map()) :: Type.ast()
  def translate_footnotes(ast, options) do
    Transform.map_ast(ast, make_translate_footnotes_mapper(options), true)
  end
end
