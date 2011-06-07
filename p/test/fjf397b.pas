{ Size of packed arrays ??? }

program fjf397b;

type
  Card7 = Cardinal attribute (Size = 7);

var
  v : packed record
    a : Char;
    b : packed array [1 .. 1] of Card7
  end = ('O', (1 : Ord ('K')));

begin
  if (SizeOf (v) >= 2) and (SizeOf (v) <= 2 * SizeOf (Integer)) then
    WriteLn (v.a, Chr (v.b [1]))
  else
    WriteLn ('failed ', SizeOf (v))
end.
