Program BO5_1a;

Type
  S2 = packed array [ 1..2 ] of Char;
  S2ptr = ^S2;

Var
  S: S2ptr;

begin
  S:= New ( S2ptr );
  S^:= 'OK';
  writeln ( S^ );
end.
