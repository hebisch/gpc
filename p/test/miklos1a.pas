Program Miklos1a;

Var
  a: packed array [ 1..7 ] of Char value '1234567';
  i : Integer;

begin
  a [ 3..4 ] := 'OK';
  a := 'OK';
  i := 7;
  while a [i] = ' ' do Dec (i);
  writeln (a : i)
end.
