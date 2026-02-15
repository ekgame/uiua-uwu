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

# Replace all occurrences of a substring in a string with another substring.
# String ? SearchSubstring ReplacementSubstring SubjectString
Replace ← ⍜⊜□(▽⊓⧻□) ⊃⊸∪⦷⋅∘
