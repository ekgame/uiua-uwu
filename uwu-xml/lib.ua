# Experimental!
Assert ~ "../uwu-assert/lib.ua"
~ "../uwu-utils/lib.ua" ~ Strings

Subscripts ← "₀₁₂₃₄₅₆₇₈₉"
Numbers    ← "0123456789"
NumberWords ← {
  "Zero" "One" "Two" "Three" "Four"
  "Five" "Six" "Seven" "Eight" "Nine"
}

KebabCase              ↚ /$"_-_" ⊜(□¯⌵) \+ ⊸= ⊸⌵
AttrsToMap!            ↚ map ∩⌞▽ ⊃(≠□""|⍚KebabCase ^|∘)
IndentNotEmpty         ↚ ⊂⊸(▽ ⊃(↧₁⧻|" "))
DigitsToWords          ↚ /◇⊂ ˜⊏ NumberWords ≡(-@0)
DigitsToSubscripts     ↚ /◇⊂ ˜⊏ Subscripts -@0
ToSafeIdentifier       ↚ ⍜⊜□⍚DigitsToWords ⊸∊Numbers
ToConvenientIdentifier ↚ ⍜⊜□⍚DigitsToSubscripts ⊸∊Numbers

┌─╴Element
  |Tag {Disc: °"__TAG"|Name: Assert!String|Attrs: Assert!Map|Children}
  |Void {Disc: °"__VOID"|Name: Assert!String|Attrs: Assert!Map}
  |Text {Disc: °"__TEXT"|Text: Assert!String}
  |RawText {Disc: °"__RAW_TEXT"|Text: Assert!String}

  NewTag     ← Tag ⊃("__TAG"|∘|map {} {}|{})
  NewVoid    ← Void ⊃("__VOID"|∘|map {} {})
  NewText    ← Text ⊃("__TEXT"|∘)
  NewRawText ← RawText ⊃("__RAW_TEXT"|∘)

  Escape ← Strings!(
    Replace "&" "&amp;"
    Replace "<" "&lt;"
    Replace ">" "&gt;"
    Replace "\"" "&quot;"
    Replace "'" "&apos;"
  )

  AttrsToString ↚ (
    # TODO: This code feels really convoluted, it should be simplified and made more readable.
    °map
    ⊸(=□"raw")
    ⊃(⍣(IndentNotEmpty °□⊢∪▽|⋅"")
    | IndentNotEmpty /$"_ _" ⍚($"_=\"_\"" ⊙Escape) ∩⌞▽¬)
    ˜⊂
  )

  DumpDebug ← |1 $"- _" ⍣(
    ⊸Assert!Struct!Tag
    Tag!⊃(
      $"<__></_>" ⊃(Name|AttrsToString Attrs|Name)
    | Strings.Indent 2 /$"_\n_" ⍚DumpDebug Children)
    $"_\n_"
  | $"<__ />" Void!⊃(Name|AttrsToString Attrs) ⊸Assert!Struct!Void
  | $"[Escaped] _"repr Text!Text ⊸Assert!Struct!Text
  | $"[Raw] _"repr RawText!Text ⊸Assert!Struct!RawText)

  ToString ← |1 ⍣(
    $"<__>_</_>" Tag!⊃(Name|AttrsToString Attrs|/◇⊂ ⍚ToString Children|Name) ⊸Assert!Struct!Tag
  | $"<__ />" Void!⊃(Name|AttrsToString Attrs) ⊸Assert!Struct!Void
  | Escape Text!Text ⊸Assert!Struct!Text
  | RawText!Text ⊸Assert!Struct!RawText)

  # Check if the value is terminal or a nested element that needs to be normalized.
  IsTerminalValue ← Assert!Is!Any!(
    Assert!Struct!Tag
  | Assert!Struct!Void
  | Assert!Struct!Text
  | Assert!Struct!RawText
  | Assert!String
  | Assert!Not!BoxType)

  NormalizeValue ← ⍣(
    ⊸Assert!Struct!Tag
  | ⊸Assert!Struct!Void
  | ⊸Assert!Struct!Text
  | ⊸Assert!Struct!RawText
  | NewText ⊸Assert!String
  | NewText "" °{}
  | NewText "" °[]
  | NewText repr)

  FlattenChildren   ← |1 ⨬(/◇⊂ ⍚FlattenChildren|□₁) ⊸IsTerminalValue
  NormalizeChildren ← ⍚NormalizeValue FlattenChildren

  TagName ← ⍣(
    Tag.Name ⊸Assert!Struct!Tag
  | Void.Name ⊸Assert!Struct!Void
  | ⍤⊙0 $"The value is not a tag or void element: _" repr
  )
└─╴

DefineAttrs ↚ (
  ⊓(◇ToSafeIdentifier|/$"_|_" ⍚$"_ ← \"\"" ⊂□"Raw")
  $$ ≁_Attrs {_} AttrsToMap!Fields
)

# Define an XML tag with the given name and possible attributes.
# Usage: DefineTag!(TagName|Attr1|Attr2|...)
DefineTag! ←^ (
  °⊂
  ⊃{DefineAttrs
  | ⊃(¯⌵∘|◇ToConvenientIdentifier|◇ToSafeIdentifier)
    ⊃(⋅∘ | ∘
    | ⋅∘ | ∘ | ⋅⋅∘)
    $$ _  ← Element~Tag!(˜°⊸Children ⊙Element~NormalizeChildren Element~NewTag "_")
    $$ _! ← Element~Tag!(˜°⊸Children ⊙Element~NormalizeChildren ˜°⊸Attrs Element~NewTag "_") _Attrs!^0
  }
  /$"_\n_"
)

# Define an XML void tag with the given name and possible attributes.
# Usage: DefineVoid!(TagName|Attr1|Attr2|...)
DefineVoid! ←^ (
  °⊂
  ⊃{DefineAttrs
  | ⊃(¯⌵∘|ToConvenientIdentifier|ToSafeIdentifier)
    ⊃(⋅∘ | ∘
    | ⋅∘ | ∘ | ⋅⋅∘)
    $$ _  ← Element~NewVoid "_"
    $$ _! ← Element~Void!(˜°⊸Attrs Element~NewVoid "_") _Attrs!^0
  }
  /$"_\n_"
)

# Create a text element with the given text content, which will not be escaped and will be displayed verbatim.
# `Tag!RawText ? String`
UnsafeRawText ← Element.NewRawText

# Render an XML element to a string.
# String ? Element
ToString ← Element.ToString

# Render an XML element to a debug string as a human-readable representation of the element's structure.
# Intended for debugging purposes, not for display. The output format may change without warning.
# String ? Element
ToDebugString ← Element.DumpDebug

┌─╴test
  DefineTag!(Div|Id|Class)
  DefineVoid!(Br|Id|Class)

  ToString Div "Hello, world!"
  ˙⍤≍ $ <div>Hello, world!</div>

  ToString Div!(°⊸Id "main" °⊸Class "container") "Hello, world!"
  ˙⍤≍ $ <div id="main" class="container">Hello, world!</div>

  ToString Br
  ˙⍤≍ $ <br />

  ToString Br!(°⊸Class "line-break")
  ˙⍤≍ $ <br class="line-break" />

  ToString Div!(°⊸Id "<b>somthing</b>") "<p onclick=\"alert(0)\">Paragraph</p>"
  ˙⍤≍ $ <div id="&lt;b&gt;somthing&lt;/b&gt;">&lt;p onclick=&quot;alert(0)&quot;&gt;Paragraph&lt;/p&gt;</div>

  ToString Div UnsafeRawText "<p onclick=\"alert(0)\">Paragraph</p>"
  ˙⍤≍ $ <div><p onclick="alert(0)">Paragraph</p></div>

  ToString Div!(°⊸Raw "data-arbitrary-attr=\"something\"") "Content"
  ˙⍤≍ $ <div data-arbitrary-attr="something">Content</div>

  ToString Div {"foo" "bar"}
  ˙⍤≍ $ <div>foobar</div>

  ToString Div {Div "Nested"}
  ˙⍤≍ $ <div><div>Nested</div></div>

  ToString Div {
    Div "Nested 1"
    Div "Nested 2"
  }
  ˙⍤≍ $ <div><div>Nested 1</div><div>Nested 2</div></div>

  ToString Div {
    {"foo" "bar"}
    {Div "Nested 1" Div "Nested 2"}
    {{Div "Nested 3"}{Div "Nested 4"}}
  }
  ˙⍤≍ $ <div>foobar<div>Nested 1</div><div>Nested 2</div><div>Nested 3</div><div>Nested 4</div></div>

  ToString Div {Br}
  ˙⍤≍ $ <div><br /></div>

  ToString Div Br
  ˙⍤≍ $ <div><br /></div>

  ToString Div ""
  ˙⍤≍ $ <div></div>

  ToString Div {}
  ˙⍤≍ $ <div></div>

  ToString UnsafeRawText "<>&\"'"
  ˙⍤≍ $ <>&"'

  ToString Div "<>&\"'"
  ˙⍤≍ $ <div>&lt;&gt;&amp;&quot;&apos;</div>

  ToString Div 1
  ˙⍤≍ $ <div>1</div>

  ToString Div [1 2 3]
  ˙⍤≍ $ <div>[1 2 3]</div>

  ToString Div {[1 2 3] [4 5 6]}
  ˙⍤≍ $ <div>[1 2 3][4 5 6]</div>
└─╴
