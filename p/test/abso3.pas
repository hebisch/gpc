Program Abso3;

{$W no-absolute}

Var
  p: ^String;
  S: String ( 2 ) absolute p^;

begin
  New ( p, 2 );
  p^:= 'OK';
  writeln ( S );
end.
