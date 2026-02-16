# Experimental!

TypeString      ↚ {"Number" "Character" "Box" "Complex"}
FormatTypeError ↚ $"Expected _ type, got _ type" ∩⌞˜⊡ TypeString
AssertType!     ↚ ⍤⊃(FormatTypeError|≍) ^ type
AppendCause!    ↚ $"_\n- _" ^

# Assert that the argument is a number type.
# ? Any
NumberType ← AssertType!0

# Assert that the argument is a character type.
# ? Any
CharacterType ← AssertType!1

# Assert that the argument is a box type.
# ? Any
BoxType ← AssertType!2

# Assert that the argument is a complex type.
# ? Any
ComplexType ← AssertType!3

# Assert the shape of the argument. Use inf to allow that dimension to be any size.
# ? Shape Any
Shape ← (
  MatchDimension ← ⍣(⋅1°∞|≍) °⊟
  ⍤⊃($"Expected shape _, got _"|/↧ ⊂1 ⧋≡MatchDimension ⬚0⊟) ⊙△
)

# Assert that the value is a boxed array and each element satisfies a predicate when unboxed.
# ? Predicate Any
Boxed! ← ⍚^ ⊸BoxType

# Assert that the value is a list and each element satisfies a predicate. A list is a 1D boxed array.
# ? Predicate Any
List! ← ⍣(Boxed!^ ⊸Shape [∞]|⍤⊙0 ⋅AppendCause!$"Expected predicated list")

# Assert that the argument is a scalar that matches a predicate. A scalar is a 0D array.
# ? Any
Scalar! ← ⍣(^ ⊸Shape []|⍤⊙0 AppendCause!$"Expected a predicated scalar, got _" repr)

# Assert that the argument does not satisfy a predicate.
# ? Predicate Any
Not! ← ⍤"Expected to fail a predicate" ⍣(0^|1)

# Assert that the argument satisfies at least one of the predicates.
# ? Predicates Any
Any! ←^ (
  /$"_|_"
  $$ ⍣(_|⍤⊙0 "Expected to match any of the predicates")
)

# Assert that the argument satisfies all of the predicates.
# ? Predicates Any
All! ←^ $"fork(_)" /$"_|_"

# Assert that the argument is a boolean array (of any shape). A boolean array contains only 0s and 1s.
# Use `Scalar!Boolean` to assert that it's a zero-dimensional value.
# ? Any
Bool ← ⍣(
  ⬚1/↧♭ ∊[0 1] ⊸NumberType
  ⍤"The array contains non-boolean values"
| ⍤⊙0 AppendCause!$"Expected a boolean array, got _" repr)

# Assert that the argument is an integer array (of any shape).
# Use `Scalar!Int` to assert that it's a zero-dimensional value.
# ? Any
Int ← ⍣(
  ≍⊸⁅ ⊸NumberType
  ⍤"The number has fractional part"
| ⍤⊙0 AppendCause!$"Expected an integer array, got _" repr)

# Assert that the argument is a string. A string is a 1D array of characters.
# ? Any
String ← ⍣(
  Shape [∞] ⊸CharacterType
| ⍤⊙0 AppendCause!$"Expected a String, got _")

# Assert that the argument is a map.
# ? Any
Map ← ⍣(◌◌°map|⍤⊙0 AppendCause!$"Expected a map, got _" repr)

# Assert that the map contains a key.
# ? Key Any
Key ← ⍣(◌get|⍤⊙0 AppendCause!$"Expected a map key _" repr)

# Assert that the argument is a map with a predicate.
# ? Predicate Any
Map! ← ⍣(^ ⊸Map|⍤⊙0 AppendCause!$"Expected a predicated map")

# Assert that the map contains a key and the value at that key satisfies a predicate.
# ? Predicate Key Any
Key! ← ⍣(^ get|⍤⊙0 ∪AppendCause!$"Expected a key _" repr)

# Assert that the map either does not contain a key or the value at that key satisfies a predicate.
# ? Predicate Key Any
OptionalKey‼ ← (
  ^0
  ⍣(⍣(⍩^1 get|◌)
  | ⍤⊙0 ∪AppendCause!$"Expected an optional key _" repr)
)

# Assert that the map contains a period-separated path ("a.b.c") and the value at that path satisfies a predicate.
# ? Predicate Path Any
Path‼ ← ⍣(
  ^1 ∧◇get °/$"_._" ^0 ⊸Map
| ⍤⊙0 ∪AppendCause!$"Expected a path _" repr ^0)

# Assert that the argument is a numeric type (scalar number or a numeric string).
# ? Any
Numeric ← ⍣(
  Any!(Scalar!NumberType|◌⋕ ⊸String)
| ⍤⊙0 $"Expected a numeric value, got _" repr)

