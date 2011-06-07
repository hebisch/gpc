{ FLAG -Wunused }

program fjf961d;

var
  i: Integer;

procedure Foo (var a);
begin
  Discard (a);
  WriteLn ('OK')
end;

begin
  Foo (i)
end.
