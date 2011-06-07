program fjf659j;

procedure Foo (a: Integer);
begin
  Finalize (a)
end;

var
  a: Integer;

begin
  Foo (a);
  WriteLn ('OK')
end.
