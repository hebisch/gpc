Program chief32a;
Type
foo = Object
end;
bar = record x:foo end;
Var
f : bar;
a, b: Integer;
begin
  FillChar (f, sizeof (f), 0);
  a := sizeof (foo);
  b := sizeof (f.x); { <- barfs at this }
  if a = b then WriteLn ('OK') else WriteLn ('failed')
end.
