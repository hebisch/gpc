program fjf659n;

procedure Foo (protected var a: Integer);
begin
  Finalize (a)  { WRONG }
end;

begin
  WriteLn ('Failed')
end.
