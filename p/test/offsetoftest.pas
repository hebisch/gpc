{ If you ever need an `OffsetOf' feature, here's how to do it
  (defined as a macro, so the ugliness is kept in one place). }

{$define OffsetOf(RECORDTYPE, FIELD) (PtrInt (@(RECORDTYPE (Null).FIELD)))}

program OffsetOfTest;

type
  Foo = record
    a: Integer;
    b: Char;
    c: ShortInt
  end;

begin
  if (OffsetOf (Foo, c) >= SizeOf (Integer) + SizeOf (Char)) and
     (OffsetOf (Foo, c) <= 2 * SizeOf (LongestInt)) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
