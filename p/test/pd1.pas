Program PD1;

Var
  m: ( foo, bar, baz );
  C: array [ 0..2 ] of Char = 'OxK';

begin
  for m in [ foo, baz ] do
    write ( C [ ord ( m ) ] );
  writeln;
end.
