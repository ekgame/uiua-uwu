# Experimental!

# TODO: "◌⊸⍤" is to make sure some bindings do not get interpreted as tests.
#       Should be removed when it's fixed.

TypeString      ↚ {"Number" "Character" "Box" "Complex"}
FormatTypeError ↚ $"Expected _ type, got _ type" ∩⌞˜⊡ TypeString
AssertType!     ↚ ◌⊸⍤⊃(FormatTypeError|≍) ^ type
AppendCause!    ↚ $"_\n- _" ^

# Assert that the argument does not satisfy a predicate.
# ? Predicate Any
Not! ← ⍤"Expected to fail a predicate" ⍣(0^|1)

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

┌─╴test
  NumberType 1
  NumberType 3.14
  NumberType [1 2 3]

  Not!NumberType @a
  Not!NumberType "hello"
  Not!NumberType □1
  Not!NumberType ℂ 1 2

  CharacterType @a
  CharacterType "hello"
  CharacterType ["qwe" "asd"]

  Not!CharacterType 1
  Not!CharacterType □1
  Not!CharacterType ℂ 1 2

  BoxType □1
  BoxType □"hello"
  BoxType □[1 2 3]
  BoxType □□1

  Not!BoxType 1
  Not!BoxType @b
  Not!BoxType ℂ 1 2

  ComplexType ℂ 1 2
  ComplexType ≡(ℂ°⊟) [1_2 3_4 5_6]

  Not!ComplexType 1
  Not!ComplexType @a
  Not!ComplexType □1
└─╴

# Assert the shape of the argument. Use inf to allow that dimension to be any size.
# ? Shape Any
Shape ← (
  MatchDimension ← ⍣(⋅1°∞|≍) °⊟
  ◌⊸⍤⊃($"Expected shape _, got _"|/↧ ⊂1 ⧋≡MatchDimension ⬚0⊟) ⊙△
)

┌─╴test
  Shape [] 1
  Shape [3] [1 2 3]
  Shape [∞] [1 2 3 4 5]
  Shape [2 2] [1_2 3_4]
  Shape [∞ 2] [1_2 3_4 5_6 7_8]

  Not!Shape [2] [1 2 3]
  Not!Shape [2 2] [1_2 3_4 5_6]
  Not!Shape [2 2] [1_2 3_4 5_6 7_8]
  Not!Shape [2 ∞] [1_2 3_4 5_6]
└─╴

# Assert that the value is a boxed array and each element satisfies a predicate when unboxed.
# ? Predicate Any
Boxed! ← ⍚^ ⊸BoxType

┌─╴test
  Boxed!NumberType □1
  Boxed!CharacterType □"hello"
  Boxed!BoxType □□1
  Boxed!ComplexType □ℂ 1 2

  Not!Boxed!NumberType □"hello"
  Not!Boxed!NumberType 1
  Not!Boxed!CharacterType □1
  Not!Boxed!CharacterType "hello"
└─╴

# Assert that the value is a list and each element satisfies a predicate. A list is a 1D boxed array.
# ? Predicate Any
List! ← ⍣(Boxed!^ ⊸Shape [∞]|⍤⊙0 ⋅AppendCause!$"Expected predicated list")

┌─╴test
  List!NumberType {1 2 3}
  List!CharacterType [□@a □@b □@c]
  List!BoxType {□1 □"hello" □[1 2 3]}
  List!ComplexType {ℂ 1 2 ℂ 3 4}

  Not!List!NumberType [1 2 3.14]
  Not!List!NumberType 1
  Not!List!CharacterType [□@a □1 □@c]
└─╴

# Assert that the argument is a scalar that matches a predicate. A scalar is a 0D array.
# ? Any
Scalar! ← ⍣(^ ⊸Shape []|⍤⊙0 AppendCause!$"Expected a predicated scalar, got _" repr)

┌─╴test
  Scalar!NumberType 1
  Scalar!CharacterType @a
  Scalar!BoxType □1
  Scalar!ComplexType ℂ 1 2

  Not!Scalar!NumberType [1 2 3]
  Not!Scalar!CharacterType "hello"
  Not!Scalar!BoxType {1 2 3}
  Not!Scalar!ComplexType [ℂ 1 2 ℂ 3 4]
└─╴

# Assert that the argument satisfies at least one of the predicates.
# ? Predicates Any
Any! ←^ (
  /$"_|_"
  $$ ⍣(_|⍤⊙0 "Expected to match any of the predicates")
)

┌─╴test
  Any!(NumberType|CharacterType) "hello"
  Any!(NumberType|CharacterType) 1
  Not!Any!(NumberType|CharacterType) □1
  Not!Any!(NumberType|CharacterType) ℂ 1 2
└─╴

# Assert that the argument satisfies all of the predicates.
# ? Predicates Any
All! ←^ $"fork(_)" /$"_|_"

┌─╴test
  All!(NumberType|Shape [3]) [1 2 3]
  Not!All!(NumberType|Shape [3]) 1
└─╴

# Assert that the argument is a boolean array (of any shape). A boolean array contains only 0s and 1s.
# Use `Scalar!Boolean` to assert that it's a zero-dimensional value.
# ? Any
Bool ← ⍣(
  ⬚1/↧♭ ∊[0 1] ⊸NumberType
  ⍤"The array contains non-boolean values"
| ⍤⊙0 AppendCause!$"Expected a boolean array, got _" repr)

┌─╴test
  Bool 1
  Bool 0
  Bool [0 1 0 1]
  Not!Bool 2
  Not!Bool [0 1 2]
  Not!Bool @a
└─╴

# Assert that the argument is an integer array (of any shape).
# Use `Scalar!Int` to assert that it's a zero-dimensional value.
# ? Any
Int ← ⍣(
  ≍⊸⁅ ⊸NumberType
  ⍤"The number has fractional part"
| ⍤⊙0 AppendCause!$"Expected an integer array, got _" repr)

┌─╴test
  Int 1
  Int ¯5
  Int [1 2 3 ¯4]
  Not!Int 3.14
  Not!Int [1 2 3.14]
  Not!Int @a
└─╴

# Assert that the argument is a string. A string is a 1D array of characters.
# ? Any
String ← ⍣(
  Shape [∞] ⊸CharacterType
| ⍤⊙0 AppendCause!$"Expected a String, got _" repr)

┌─╴test
  String "hello"
  String ""
  # Not!String @a
  Not!String □"hello"
  Not!String 123
└─╴

# Assert that the argument is a byte array. A byte array is a 1D array of numbers between 0 and 255.
# ? Any
ByteArray ← ⍣(
  ⬚1/↧↧ ⊃≥₀<₂₅₆ ⊸Shape [∞] ⊸Int
  ⍤"Array contains values outside of a byte range"
| ⍤⊙0 AppendCause!$"Expected a ByteArray, got _" repr)

┌─╴test
  ByteArray [1 2 3]
  ByteArray [0 255 128]
  Not!ByteArray [1 2 256]
  Not!ByteArray [¯1 0 1]
  Not!ByteArray [1.23 4.56]
  Not!ByteArray @a
└─╴

# Assert that the argument is a map.
# ? Any
Map ← ⍣(◌◌°map|⍤⊙0 AppendCause!$"Expected a map, got _" repr)

┌─╴test
  Map map [1 2 3] [4 5 6]
  Not!Map [1 2 3]
└─╴

# Assert that the map contains a key.
# ? Key Any
Key ← ⍣(◌get|⍤⊙0 AppendCause!$"Expected a map key _" repr)

┌─╴test
  Key 1 map [1 2 3] [4 5 6]
  Not!Key 4 map [1 2 3] [4 5 6]
└─╴

# Assert that the argument is a map with a predicate.
# ? Predicate Any
Map! ← ⍣(^ ⊸Map|⍤⊙0 AppendCause!$"Expected a predicated map")

# Assert that the map contains a key and the value at that key satisfies a predicate.
# ? Predicate Key Any
Key! ← ⍣(^ get|⍤⊙0 ∪AppendCause!$"Expected a key _" repr)

# Assert that the map either does not contain a key or the value at that key satisfies a predicate.
# ? Predicate Key Any
OptionalKey! ← (
  ⍣(⍣(⍩^ get|◌)
  | ⍤⊙0 ∪AppendCause!$"Expected an optional key _" repr)
)

# Assert that the map contains a period-separated path ("a.b.c") and the value at that path satisfies a predicate.
# ? Predicate Path Any
Path‼ ← ⍣(
  ^1 ∧◇get °/$"_._" ^0 ⊸Map
| ⍤⊙0 ∪AppendCause!$"Expected a path _" repr ^0)

┌─╴test
  ┌─╴MapBuilder
    Set    ← insert ∩□
    New    ← map {} {}
    Build! ← MapBuilder!^ New
  └─╴

  MapBuilder~Build!(
    Set "hello" "world"
    Set 1 2
    Set "optional" 3
    Set "nested" Build!(
      Set "a" 1
      Set "b" [1 2 3]
    )
  )

  Map!(
    ⊸Key!Boxed!String "hello"
    ⊸Key!Boxed!NumberType 1
    ⊸OptionalKey!Boxed!Int "optional"
    ⊸OptionalKey!Boxed!Int "optionalNonexistent"
    ⊸Key!Boxed!Map!(
      ⊸Key!Boxed!Scalar!Int "a"
      ⊸Key!Boxed!Int "b"
      ◌
    ) "nested"
    ⊸Path‼("nested.a"|Boxed!Scalar!Int)
    ◌
  )
└─╴

# Assert that the argument is a numeric type (scalar number or a numeric string).
# ? Any
Numeric ← ⍣(
  Any!(Scalar!NumberType|◌⋕ ⊸String)
| ⍤⊙0 $"Expected a numeric value, got _" repr)

┌─╴test
  Numeric 1
  Numeric 3.14
  Numeric "42"

  Not!Numeric "hello"
  Not!Numeric @a
  Not!Numeric □1
└─╴

# Assert that the argument matches the shape of the struct.
# ? Struct Any
Struct! ← ⍣(◌^°^|⍤⊙0 AppendCause!$"Expected a struct, got _" repr)

┌─╴test
  ~TestStruct {
    A: Scalar!Int
    B: List!String
  }

  Struct!TestStruct {67 {"foo" "bar"}}
  Not!Struct!TestStruct {"not an int" "not a list"}
└─╴

# Assert that the argument is a Uiua handle.
# 
# Note: there isn't really a way to make sure this value is a hanlde,
# but Uiua handles are always boxed integers, so this is at least a sanity check.
# ? Any
Handle ← ⍣(Boxed!Scalar!Int|⍤⊙0 $"Expected a Uiua handle, got _" repr)

# Assert that the argument is a stream handle.
# ? Any
StreamHandle ← Handle

# Assert that the argument is a file handle.
# ? Any
FileHandle ← Handle

┌─╴test
  Handle □1
  Not!Handle 1
  Not!Handle @a
└─╴
