~ "xml.ua" ~ DefineTag! DefineVoid!
~ "../uwu-utils/lib.ua" ~ Strings

# All tags: https://www.w3schools.com/tags
# Global attributes: https://www.w3schools.com/tags/ref_standardattributes.asp

GlobalAttributes ← /$"_|_" {
  "Accesskey|Class|Contenteditable|Dir|Draggable|Enterkeyhint|Hidden|Id|Inert"
  "Inputmode|Lang|Popover|Spellcheck|Style|Tabindex|Title|Translate"
}

(
  DefineHtmlElement ← $"DefineTag!(_)" /$"_|_" ˜⊂□GlobalAttributes □
  DefineHtmlVoidElement ← $"DefineVoid!(_)" /$"_|_" ˜⊂□GlobalAttributes □

  /$"_\n_" {
    DefineHtmlElement "A|Download|Href|Hreflang|Media|Ping|Referrerpolicy|Rel|Target|Type"
    DefineHtmlElement "Abbr"
    DefineHtmlElement "Address"
    DefineHtmlVoidElement "Area|Alt|Coords|Download|Href|Hreflang|Media|Ping|Referrerpolicy|Rel|Shape|Target|Type"
    DefineHtmlElement "Article"
    DefineHtmlElement "Aside"
    DefineHtmlElement "Audio|Autoplay|Controls|Loop|Muted|Preload|Src"
    DefineHtmlElement "B"
    DefineHtmlVoidElement "Base|Href|Target"
    DefineHtmlElement "Bdi"
    DefineHtmlElement "Bdo|Dir"
    DefineHtmlElement "Blockquote|Cite"
    DefineHtmlElement "Body"
    DefineHtmlVoidElement "Br"
    DefineHtmlElement "Button|Autofocus|Disabled|Form|Formaction|Formenctype|Formmethod|Formnovalidate|Formtarget|Popovertarget|Popovertargetaction|Name|Type|Value"
    DefineHtmlElement "Canvas|Height|Width"
    DefineHtmlElement "Caption"
    DefineHtmlElement "Cite"
    DefineHtmlElement "Code"
    DefineHtmlVoidElement "Col|Span"
    DefineHtmlElement "Colgroup|Span"
    DefineHtmlElement "Data|Value"
    DefineHtmlElement "Datalist"
    DefineHtmlElement "Dd"
    DefineHtmlElement "Del|Cite|Datetime"
    DefineHtmlElement "Details|Open|Name"
    DefineHtmlElement "Dfn"
    DefineHtmlElement "Dialog|Open"
    DefineHtmlElement "Div"
    DefineHtmlElement "Dl"
    DefineHtmlElement "Dt"
    DefineHtmlElement "Em"
    DefineHtmlVoidElement "Embed|Height|Src|Type|Width"
    DefineHtmlElement "Fieldset|Disabled|Form|Name"
    DefineHtmlElement "Figcaption"
    DefineHtmlElement "Figure"
    DefineHtmlElement "Footer"
    DefineHtmlElement "Form|AcceptCharset|Action|Autocomplete|Enctype|Method|Name|Novalidate|Rel|Target"
    DefineHtmlElement "H1"
    DefineHtmlElement "H2"
    DefineHtmlElement "H3"
    DefineHtmlElement "H4"
    DefineHtmlElement "H5"
    DefineHtmlElement "H6"
    DefineHtmlElement "Head"
    DefineHtmlElement "Header"
    DefineHtmlElement "Hgroup"
    DefineHtmlVoidElement "Hr"
    DefineHtmlElement "Html|Manifest|Lang"
    DefineHtmlElement "I"
    DefineHtmlElement "Iframe|Allow|Allowfullscreen|Allowpaymentrequest|Height|Loading|Name|Referrerpolicy|Sandbox|Src|Srcdoc|Width"
    DefineHtmlVoidElement "Img|Alt|Crossorigin|Height|Ismap|Loading|Longdesc|Referrerpolicy|Sizes|Src|Srcset|Usemap|Width"
    DefineHtmlVoidElement "Input|Accept|Alt|Autocomplete|Autofocus|Checked|Dirname|Disabled|Form|Formaction|Formenctype|Formmethod|Formnovalidate|Formtarget|Height|List|Max|Maxlength|Min|Minlength|Multiple|Name|Pattern|Placeholder|Popovertarget|Popovertargetaction|Readonly|Required|Size|Src|Step|Type|Value|Width"
    DefineHtmlElement "Ins|Cite|Datetime"
    DefineHtmlElement "Kbd"
    DefineHtmlElement "Label|For|Form"
    DefineHtmlElement "Legend"
    DefineHtmlElement "Li|Value"
    DefineHtmlVoidElement "Link|Crossorigin|Href|Hreflang|Referrerpolicy|Media|Integrity|Rel|Sizes|Title|Type"
    DefineHtmlElement "Main"
    DefineHtmlElement "Map|Name"
    DefineHtmlElement "Mark"
    DefineHtmlElement "Menu"
    DefineHtmlVoidElement "Meta|Charset|Content|HttpEquiv|Name"
    DefineHtmlElement "Meter|Form|High|Low|Max|Min|Optimum|Value"
    DefineHtmlElement "Nav"
    DefineHtmlElement "Noscript"
    DefineHtmlElement "Object|Data|Form|Height|Name|Type|Typemustmatch|Usemap|Width"
    DefineHtmlElement "Ol|Reversed|Start|Type"
    DefineHtmlElement "Optgroup|Disabled|Label"
    DefineHtmlElement "Option|Disabled|Label|Selected|Value"
    DefineHtmlElement "Output|For|Form|Name"
    DefineHtmlElement "P"
    DefineHtmlVoidElement "Param|Name|Value"
    DefineHtmlElement "Picture"
    DefineHtmlElement "Pre"
    DefineHtmlElement "Progress|Max|Value"
    DefineHtmlElement "Q|Cite"
    DefineHtmlElement "Rp"
    DefineHtmlElement "Rt"
    DefineHtmlElement "Ruby"
    DefineHtmlElement "S"
    DefineHtmlElement "Samp"
    DefineHtmlElement "Script|Async|Crossorigin|Defer|Integrity|Nomodule|Referrerpolicy|Src|Type"
    DefineHtmlElement "Search"
    DefineHtmlElement "Section"
    DefineHtmlElement "Select|Autofocus|Disabled|Form|Multiple|Name|Required|Size"
    DefineHtmlElement "Small"
    DefineHtmlVoidElement "Source|Media|Sizes|Src|Srcset|Type"
    DefineHtmlElement "Span"
    DefineHtmlElement "Strong"
    DefineHtmlElement "Style|Media|Type"
    DefineHtmlElement "Sub"
    DefineHtmlElement "Summary"
    DefineHtmlElement "Sup"
    DefineHtmlElement "Svg|Height|Preserveaspectratio|Viewbox|Width"
    DefineHtmlElement "Table|Border"
    DefineHtmlElement "Tbody"
    DefineHtmlElement "Td|Colspan|Headers|Rowspan"
    DefineHtmlElement "Template"
    DefineHtmlElement "Textarea|Autofocus|Cols|Dirname|Disabled|Form|Maxlength|Name|Placeholder|Readonly|Required|Rows|Wrap"
    DefineHtmlElement "Tfoot"
    DefineHtmlElement "Th|Abbr|Colspan|Headers|Rowspan|Scope"
    DefineHtmlElement "Thead"
    DefineHtmlElement "Time|Datetime"
    DefineHtmlElement "Title"
    DefineHtmlElement "Tr"
    DefineHtmlVoidElement "Track|Default|Kind|Label|Src|Srclang"
    DefineHtmlElement "U"
    DefineHtmlElement "Ul"
    DefineHtmlElement "Var"
    DefineHtmlElement "Video|Autoplay|Controls|Height|Loop|Muted|Poster|Preload|Src|Width"
    DefineHtmlVoidElement "Wbr"
  }
)^!∘

WithDoctype ← ⊂$"<!DOCTYPE _>\n"
Comment     ← $"<!-- _ -->"

# Re-export the html element to include doctype.
# Re-export html, head and body to require body for convenience.

HtmlInner‼ ↚ WithDoctype "html" Html‼^0^1
Html       ← HtmlInner‼∘∘
Html!      ← HtmlInner‼^∘

InnerBody‼ ↚ Body‼^0^1
Body       ← InnerBody‼∘∘
Body!      ← InnerBody‼^∘

InnerHead‼ ↚ Head‼^0^1
Head       ← InnerHead‼∘∘
Head!      ← InnerHead‼^∘

Escape ← Strings!(
  Replace "&" "&amp;"
  Replace "<" "&lt;"
  Replace ">" "&gt;"
  Replace "\"" "&quot;"
  Replace "'" "&apos;"
)
