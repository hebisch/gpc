program fjf659g;

procedure Foo (protected var a: Integer);
begin
  Initialize (a)  { WRONG }
end;

begin
  WriteLn ('Failed')
end.
