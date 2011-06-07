program fjf659e;

procedure Foo (const a: Integer);
begin
  Initialize (a)  { WRONG }
end;

begin
  WriteLn ('Failed')
end.
