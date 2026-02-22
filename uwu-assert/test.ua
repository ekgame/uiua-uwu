# Experimental!

Assert ~ "lib.ua"

ExpectFail! ← ⍣(⍩⍤"Expected an assertion to fail, but it succeeded"0 ^|⋅◌)

Assert!NumberType 1
Assert!NumberType 3.14
Assert!NumberType [1 2 3]

ExpectFail!Assert!NumberType @a
ExpectFail!Assert!NumberType "hello"
ExpectFail!Assert!NumberType □1
ExpectFail!Assert!NumberType ℂ 1 2

Assert!CharacterType @a
Assert!CharacterType "hello"
Assert!CharacterType ["qwe" "asd"]

ExpectFail!Assert!CharacterType 1
ExpectFail!Assert!CharacterType □1
ExpectFail!Assert!CharacterType ℂ 1 2

Assert!BoxType □1
Assert!BoxType □"hello"
Assert!BoxType □[1 2 3]
Assert!BoxType □□1

ExpectFail!Assert!BoxType 1
ExpectFail!Assert!BoxType @b
ExpectFail!Assert!BoxType ℂ 1 2

Assert!ComplexType ℂ 1 2
Assert!ComplexType ≡(ℂ°⊟) [1_2 3_4 5_6]

ExpectFail!Assert!ComplexType 1
ExpectFail!Assert!ComplexType @a
ExpectFail!Assert!ComplexType □1

Assert!Shape [] 1
Assert!Shape [3] [1 2 3]
Assert!Shape [∞] [1 2 3 4 5]
Assert!Shape [2 2] [1_2 3_4]
Assert!Shape [∞ 2] [1_2 3_4 5_6 7_8]

ExpectFail!Assert!Shape [2] [1 2 3]
ExpectFail!Assert!Shape [2 2] [1_2 3_4 5_6]
ExpectFail!Assert!Shape [2 2] [1_2 3_4 5_6 7_8]
ExpectFail!Assert!Shape [2 ∞] [1_2 3_4 5_6]

Assert!Boxed!NumberType □1
Assert!Boxed!CharacterType □"hello"
Assert!Boxed!BoxType □□1
Assert!Boxed!ComplexType □ℂ 1 2

ExpectFail!Assert!Boxed!NumberType □"hello"
ExpectFail!Assert!Boxed!NumberType 1
ExpectFail!Assert!Boxed!CharacterType □1
ExpectFail!Assert!Boxed!CharacterType "hello"

Assert!List!NumberType {1 2 3}
Assert!List!CharacterType [□@a □@b □@c]
Assert!List!BoxType {□1 □"hello" □[1 2 3]}
Assert!List!ComplexType {ℂ 1 2 ℂ 3 4}

ExpectFail!Assert!List!NumberType [1 2 3.14]
ExpectFail!Assert!List!NumberType 1
ExpectFail!Assert!List!CharacterType [□@a □1 □@c]

Assert!Scalar!NumberType 1
Assert!Scalar!CharacterType @a
Assert!Scalar!BoxType □1
Assert!Scalar!ComplexType ℂ 1 2

ExpectFail!Assert!Scalar!NumberType [1 2 3]
ExpectFail!Assert!Scalar!CharacterType "hello"
ExpectFail!Assert!Scalar!BoxType {1 2 3}
ExpectFail!Assert!Scalar!ComplexType [ℂ 1 2 ℂ 3 4]

Assert!Not!NumberType @a
ExpectFail!Assert!Not!NumberType 1

Assert!Any!(NumberType|CharacterType) "hello"
Assert!Any!(NumberType|CharacterType) 1
ExpectFail!Assert!Any!(NumberType|CharacterType) □1
ExpectFail!Assert!Any!(NumberType|CharacterType) ℂ 1 2

Assert!All!(NumberType|Shape [3]) [1 2 3]
ExpectFail!Assert!All!(NumberType|Shape [3]) 1

Assert!Bool 1
Assert!Bool 0
Assert!Bool [0 1 0 1]
ExpectFail!Assert!Bool 2
ExpectFail!Assert!Bool [0 1 2]
ExpectFail!Assert!Bool @a

Assert!Int 1
Assert!Int ¯5
Assert!Int [1 2 3 ¯4]
ExpectFail!Assert!Int 3.14
ExpectFail!Assert!Int [1 2 3.14]
ExpectFail!Assert!Int @a

Assert!ByteArray [1 2 3]
Assert!ByteArray [0 255 128]
ExpectFail!Assert!ByteArray [1 2 256]
ExpectFail!Assert!ByteArray [¯1 0 1]
ExpectFail!Assert!ByteArray [1.23 4.56]
ExpectFail!Assert!ByteArray @a

Assert!Map map [1 2 3] [4 5 6]
ExpectFail!Assert!Map [1 2 3]

Assert!Key 1 map [1 2 3] [4 5 6]
ExpectFail!Assert!Key 4 map [1 2 3] [4 5 6]

┌╶╶BuildMapInternal
  Set ← insert ∩□
  New ← map {} {}
└╶╶

BuildMap! ← BuildMapInternal!^ BuildMapInternal!New

BuildMap!(
  Set "hello" "world"
  Set 1 2
  Set "nested" BuildMap!(
    Set "a" 1
    Set "b" [1 2 3]
  )
)
Assert!Map!(
  ⊸Key!Boxed!String "hello"
  ⊸Key!Boxed!NumberType 1
  ⊸Key!Boxed!Map!(
    ⊸Key!Boxed!Scalar!Int "a"
    ⊸Key!Boxed!Int "b"
    ◌
  ) "nested"
  ◌
)

Assert!Numeric 1
Assert!Numeric 3.14
Assert!Numeric "42"
ExpectFail!Assert!Numeric "hello"
ExpectFail!Assert!Numeric @a
ExpectFail!Assert!Numeric □1

~TestStruct {
  A: Assert!Scalar!Int
  B: Assert!List!String
}

Assert!Struct!TestStruct {67 {"foo" "bar"}}
ExpectFail!Assert!Struct!TestStruct {"not an int" "not a list"}

Assert!Handle □1
ExpectFail!Assert!Handle 1
ExpectFail!Assert!Handle @a
