program fjf682;

var
  a: array [-2 .. 3] of Char = 'FGHIJK';
  b: ^Char;

begin
  b := @a[2];
  b^ := 'O';
  WriteLn (a[2 .. 3])
end.
