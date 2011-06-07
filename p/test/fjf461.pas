program fjf461;

procedure foo (const bar);
begin
  WriteLn ('failed')
end;

begin
  foo (1) { WRONG }
end.
