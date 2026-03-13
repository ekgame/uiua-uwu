Assert ~ "../uwu-assert/lib.ua"

NormalizePath ← (
  ApplySegment ← ⍣(
    ∘°"" | ∘°"."
  | ⍣(˜⊂□".." ⊸⍣(°{}|°".."°□⊣)|↘¯1) °".."
  | ˜⊂□
  )

  ⊸Assert!String
  ⍜°/$"_/_"(∧◇ApplySegment ⊙{})
)
