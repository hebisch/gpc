Program chief32;
Type
foo = Object
end;
Var
f : foo;
a, b: Integer;
begin
  a := sizeof (foo);
  b := sizeof (f); { <- barfs at this }
  if a = b then WriteLn ('OK') else WriteLn ('failed')
end.
