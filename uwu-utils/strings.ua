Whitespace ← " \n\r\t"

TrimStartMask ↚ \↥¬∊Whitespace
TrimEndMask   ↚ ⍜⇌TrimStartMask
TrimMask      ↚ ↧⊃(TrimStartMask|TrimEndMask)

# Trim whitespace from the start of a string.
TrimStart ← ▽⊸TrimStartMask

# Trim whitespace from the end of a string.
TrimEnd ← ▽⊸TrimEndMask

# Trim whitespace from both ends of a string.
Trim ← ▽⊸TrimMask
