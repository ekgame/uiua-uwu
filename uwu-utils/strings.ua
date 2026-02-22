# Experimental!

Whitespace ↚ " \n\r\t"

TrimStartMask ↚ \↥¬∊Whitespace
TrimEndMask   ↚ ⍜⇌TrimStartMask
TrimMask      ↚ ↧⊃(TrimStartMask|TrimEndMask)

# Trim whitespace from the start of a string.
# String ? String
TrimStart ← ▽⊸TrimStartMask

# Trim whitespace from the end of a string.
# String ? String
TrimEnd ← ▽⊸TrimEndMask

# Trim whitespace from both ends of a string.
# String ? String
Trim ← ▽⊸TrimMask

┌─╴test
  ˙⍤≍ "hello   " TrimStart "   hello   "
  ˙⍤≍ "   hello" TrimEnd "   hello   "
  ˙⍤≍ "hello" Trim "   hello   "
└─╴

# Replace all occurrences of a substring in a string with another substring.
# String ? SearchSubstring ReplacementSubstring SubjectString
Replace ← ⍜⊜□(▽⊓⧻□) ⊃⊸∪⦷⋅∘

┌─╴test
  ˙⍤≍ "hello world" Replace "there" "world" "hello there"
  ˙⍤≍ "aaaaa" Replace "b" "a" "bbbbb"
  ˙⍤≍ "hello world" Replace "x" "y" "hello world"
  ˙⍤≍ "ababab" Replace "cd" "ab" "cdcdcd"
└─╴
