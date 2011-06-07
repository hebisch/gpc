Program ForVars2 ( Output );

{ FLAG -Werror --classic-pascal }

Var
  a: packed array [ 1..2 ] of Char;
  i: Integer;

begin
  a:= 'OK';
  for i:= 1 to 2 do
    write ( a [ i ] );
  writeln;
end.
