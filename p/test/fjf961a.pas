{ FLAG -Wunused }

program fjf961a;

procedure Foo (a: Integer);
begin
  Discard (a);
  WriteLn ('OK')
end;

begin
  Foo (42)
end.
