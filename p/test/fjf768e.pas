program fjf768e;

var
  b: array [0 .. 1] of 0 .. 1 = (0, 0);
  x: Byte = 0;

{$borland-pascal}

begin
  if 0 in [b[x mod 2], 0] then WriteLn ('OK')  { No warning here }
end.
