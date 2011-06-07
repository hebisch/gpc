program fjf655a;

procedure Test (const Foo: array of Char);
begin
  if (Low (Foo) = 0) and (High (Foo) = 1) then
    WriteLn (Foo)
  else
    WriteLn ('failed ', Low (Foo), ' ', High (Foo))
end;

begin
  Test ('OK')
end.
