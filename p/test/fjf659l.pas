program fjf659l;

procedure Foo (const a: Integer);
begin
  Finalize (a)  { WRONG }
end;

begin
  WriteLn ('Failed')
end.
