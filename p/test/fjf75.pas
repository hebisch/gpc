program fjf75;

procedure p;
var a:integer;

  procedure q; attribute (inline);
  begin
    if a = a then
      writeln ( 'OK' );
  end;

begin
  q;
end;

begin
  p;
end.
