defmodule SemanticMarkdown.Type do
  @moduledoc """
  `SemanticMarkdown.Type` is a module containing used types within
  `SemanticMarkdown`
  """
  @type ast_tuple :: Earmark.ast_tuple
  @type ast :: Earmark.ast

  @typedoc """
  Keyword list of options.

  Available options:

  ### Own
  - `footnotes_see` - Title of footnote link (default: `"see footnote"`), see [Foonotes Rationale](./README.md#footnotes)
  - `footnotes_return` - Same as above but for the return link (default: `"return to article"`)
  - `clean_semantic_tags` - whether should the parsed semantic tags be removed from AST before transforming (default: `true`)
  - `clean_empty_paragraphs` - whether empty paragraphs should be removed. (default: `true`)
  - `earmark_inner_transform` - whether parsed inner tags should be re-parsed once more as Markdown (default: `true`)

  ### `Earmark`'s
  - `footnotes` - whether `Earmark` should parse footnotes (default: `true`)
  - `earmark_transform_options` - options passed directly to `Earmark.transform` (default: `%{}`)
  """
  @type options() :: [option()]
  @type option() ::
  {:footnotes, boolean()}
  | {:footnotes_see, String.t}
  | {:footnotes_return, String.t}
  | {:clean_semantic_tags, boolean()}
  | {:clean_empty_paragraphs, boolean()}
  | {:earmark_inner_transform, boolean()}
  | {:earmark_transform_options, %{}}

  @type options_map() :: %{
    footnotes: boolean(),
    footnotes_see: String.t,
    footnotes_return: String.t,
    clean_newlines: boolean(),
    earmark_inner_transform: boolean(),
    earmark_inner_semantic: boolean(),
    earmark_transform_options: %{},
    content_tag_name: String.t,
    merge_content: boolean(),
    tags: [atom()]
  }

  @type semantic_inner_ast :: {String.t, [Keyword.t], ast} | {String.t, [Keyword.t]}

  @typedoc """
  Keyword list containing Markdown transformed into HTML.

  Minimal result is `[content: String.t]` representing parsed input string,
  where _content_ key is configurable.

  Parsed semantic tags can be either in form of:
  - `{tag_name :: atom(), tag_content :: String.t}`
  - `{tag_name :: atom(), tag :: [semantic_tag]}`

  There are 2 special keys:
  - `content` that contains parsed markdown content
  - `attributes` that contains XML tag attributes
  """
  @type result() :: [{atom(), content()}, ...]

  @type content_map :: %{
    attributes: [Keyword.t],
    content: [String.t] | String.t
  }
  @type content() ::
  content_map()
  | String.t()
  | boolean()


end
