program fjf768f;

var
  b: array [0 .. 1] of 0 .. 1 = (0, 0);
  x: ByteInt = 1;

{$borland-pascal}

begin
  if 0 in [b[2 mod x], 0] then WriteLn ('OK')  { No warning here }
end.
