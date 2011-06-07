program fjf397;

var
  v : packed record
    a : Char;
    b : packed array [1 .. 1] of Char
  end = ('O', ('K'));

begin
  if SizeOf (v) = 2 then
    WriteLn (v.a, v.b [1])
  else
    WriteLn ('failed ', SizeOf (v))
end.
