Program DelInsPos;

{$borland-pascal}

Var
  S: String;

begin
  S:= 'barKUKKUU';
  Insert ( 'FOO', S, 1 );
  Delete ( S, pos ( 'bar', S ), 6 );
  S:= copy ( S, 3, 2 );
  writeln ( S );
end.
