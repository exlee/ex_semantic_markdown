defmodule SemanticMarkdown.Inner do
  @moduledoc """
  `SemanticMarkdown.Inner` Contains inner implementation of Markdown parser, including `transform` that allows to work on the `Earmark`'s AST tree directly and `transform_text` that takes processed `SemanticMarkdown.Type.options_map()`.
  """
  alias SemanticMarkdown.{AST, Type}
  import AST, only: [is_temporary_tag: 1]

  @spec transform_inner_semantic(Type.ast_tuple(), Type.options_map()) :: Type.content_map()
  defp transform_inner_semantic(
         {node_name, attributes, value, meta},
         %{earmark_inner_transform: true} = options
       ) do
    %{
      attributes: attributes,
      content: transform_text_inner(value, options)
    }
  end

  defp transform_inner_semantic({node_name, attributes, value, meta}, _) do
    %{
      attributes: attributes,
      content: value
    }
  end

  @spec clean_content(Type.content() | {atom(), Type.content()}) ::
          Type.content() | {atom(), Type.content()}
  defp clean_content(%{attributes: [], content: []}), do: true
  defp clean_content(%{attributes: [], content: [value]}), do: value
  defp clean_content(%{attributes: [], content: value}), do: value
  defp clean_content(v), do: v

  defp clean_content(key, value), do: {key, clean_content(value)}

  @spec remove_newlines(String.t(), Type.options_map()) :: String.t()
  def remove_newlines(text, %{clean_newlines: true}) do
    String.replace(text, "\n", "")
  end

  def remove_newlines(text, _), do: text

  @spec transform_node({String.t() | atom(), Type.ast_tuple()}, Type.options_map()) ::
          {atom(), String.t() | Type.content()}
  def transform_node({tag, value}, options) when is_temporary_tag(tag) do
    Earmark.transform(value, options.earmark_transform_options) |> remove_newlines(options)
  end

  def transform_node({tag, value}, options) do
    {
      tag,
      clean_content(transform_inner_semantic(value, options))
    }
  end

  @spec transform({atom() | String.t(), Type.ast_tuple()}, Type.options_map()) ::
          {atom(), Type.content()}
  def transform({key, value} = pair, opts) do
    pair
    |> transform_node(opts)
    |> clean_content
  end

  @spec merge_content(Type.result(), Type.options_map()) :: Type.result()
  def merge_content(content, %{merge_content: true, content_tag_name: tag}) do
    merged =
      Enum.reduce(content, "", fn
        {^tag, text}, acc -> acc <> "\n" <> text
        node, acc -> acc
      end)

    Enum.filter(content, fn {k, v} -> k != tag end) ++ [content: merged]
  end

  def merge_content(content, options), do: content

  @spec transform_text_inner([String.t()], Type.options_map()) :: Type.result() | []
  def transform_text_inner([], opts), do: []

  def transform_text_inner([text], opts) do
    ast =
      Earmark.as_ast!(text, annotations: "%>", footnotes: opts[:footnotes], compact_output: true)

    ast
    |> AST.translate_footnotes(opts)
    |> AST.preparse(opts)
    |> Enum.map(&transform(&1, opts))
  end

  @spec tag_strings(String.t() | {atom, any}, Type.options_map()) :: {atom, any}
  def tag_strings(value, options) when is_bitstring(value) do
    {String.to_atom(options.content_tag_name), value}
  end

  def tag_strings(value, _), do: value

  @spec transform_text(String.t(), Type.options_map()) :: Type.result()
  def transform_text(text, opts) do
    transform_text_inner([text], opts)
    |> merge_content(opts)
    |> Enum.map(&tag_strings(&1, opts))
  end
end
