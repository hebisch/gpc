program fjf891a;

type
  t = Cardinal attribute (Size = 12);

var
  a: packed array [1 .. 10] of t;
  b: packed record c: t end;
  d: Integer = 4;

begin
  if (BitSizeOf (a[2]) = 12) and (BitSizeOf (a[d]) = 12) and (BitSizeOf (b.c) = 12) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', BitSizeOf (a[2]), ' ', BitSizeOf (a[d]), ' ', BitSizeOf (b.c))
end.
