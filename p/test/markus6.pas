Program markus6;

  uses
    markus6u;

  var
    i: integer;

begin
  new ( pruzzel, 10000 );
  for i:= 1 to 10000 do
    pruzzel^ [ i ]:= 1;
  dispose ( pruzzel );
  writeln ( 'OK' );
end.
