program fjf569i;

procedure foo (protected a: String);
begin
  WriteStr (a, '')  { WRONG }
end;

begin
  WriteLn ('')
end.
