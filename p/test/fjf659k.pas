program fjf659k;

procedure Foo (var a: Integer);
begin
  Finalize (a)
end;

var
  a: Integer;

begin
  Foo (a);
  WriteLn ('OK')
end.
