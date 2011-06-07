program fjf659f;

procedure Foo (protected a: Integer);
begin
  Initialize (a)  { WRONG }
end;

begin
  WriteLn ('Failed')
end.
