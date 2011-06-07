{ FLAG -Wunused }

program fjf961e;

var
  i: Integer;

procedure Foo (const a);
begin
  Discard (a);
  WriteLn ('OK')
end;

begin
  Foo (i)
end.
