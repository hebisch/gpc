program fjf569g;

procedure foo (protected a: Integer);
begin
  Read (a)  { WRONG }
end;

begin
  WriteLn ('failed')
end.
