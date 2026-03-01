# Experimental!

≁Tag {
  Name ← ""
  Attrs ← map {} {}
  Children ← {}
}

≁Void {
  Name ← ""
  Attrs ← map {} {}
}

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

AttrsToString ↚ (
  °map
  ⊸(=□"raw")
  ⊃(⍣(IndentNotEmpty °□⊢∪▽|⋅"")
  | IndentNotEmpty /$"_ _" ⍚$"_=\"_\"" ∩⌞▽¬)
  ˜⊂
)

TagToString ↚ (
  ConcatStrings ← ⬚""/◇⊂ ⬚""⍚/◇⊂

  $"<__>_</_>" Tag!⊃(
    Name
  | AttrsToString Attrs
  | ConcatStrings Children
  | Name)
)

VoidToString ↚ $"<__ />" Void!⊃(Name|AttrsToString Attrs)

DefineAttrs ← (
  ⊓(◇ToSafeIdentifier|/$"_|_" ⍚$"_ ← \"\"" ⊂□"Raw")
  $$ ≁_Attrs {_} AttrsToMap!Fields
)

DefineTag! ←^ (
  °⊂
  ⊃{DefineAttrs
  | ⊃(¯⌵∘|◇ToConvenientIdentifier|◇ToSafeIdentifier)
    ⊃(⋅∘ | ∘
    | ⋅∘ | ∘ | ⋅⋅∘)
    $$ _  ← TagToString Tag!(˜°⊸Children °⊸Name "_" New)
    $$ _! ← TagToString Tag!(˜°⊸Children ˜°⊸Attrs °⊸Name "_" New) _Attrs!^0
  }
  /$"_\n_"
)

DefineVoid! ←^ (
  °⊂
  ⊃{DefineAttrs
  | ⊃(¯⌵∘|ToConvenientIdentifier|ToSafeIdentifier)
    ⊃(⋅∘ | ∘
    | ⋅∘ | ∘ | ⋅⋅∘)
    $$ _  ← VoidToString Tag!(°⊸Name "_" New)
    $$ _! ← VoidToString Void!(˜°⊸Attrs °⊸Name "_" New) _Attrs!^0
  }
  /$"_\n_"
)
