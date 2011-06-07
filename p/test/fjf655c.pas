program fjf655c;

procedure Test (const Foo: packed array [m .. n: Integer] of Char);
begin
  if (m = 1) and (n = 2) and (Low (Foo) = 1) and (High (Foo) = 2) then
    WriteLn (Foo)
  else
    WriteLn ('failed ', m, ' ', n, ' ', Low (Foo), ' ', High (Foo))
end;

begin
  Test ('OK')
end.
