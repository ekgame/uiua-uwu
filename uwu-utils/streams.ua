# Experimental!

Assert ~ "../uwu-assert/lib.ua"

# Read precisely the specified amount of bytes from the stream.
# Uiua's &rb returns an indefinite amount of bytes, where the first argument is an upper bound.
# This function will read from the stream until it has read the specified amount of bytes, or until it reaches EOF.
# ByteArray ? Length StreamHandle
~ReadBytes {
  Length: Assert!Scalar!Int
  StreamHandle: Assert!StreamHandle
  Buffer ← []
  Eof ← 0
} (
  ⍢(⨬(˜⍜Buffer⊂|°⊸Eof 1) ⊸(≍[]) &rb ⊸⊃(Length|StreamHandle)
  | /↧ ⊃[>⊃(⧻Buffer|Length)|¬Eof])
  Buffer
)
