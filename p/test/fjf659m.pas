program fjf659m;

procedure Foo (protected a: Integer);
begin
  Finalize (a)  { WRONG }
end;

begin
  WriteLn ('Failed')
end.
