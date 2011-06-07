program fjf268b;

procedure foo (const s : string);
begin
  delete (s, 1, 1) { WRONG }
end;

begin
  writeln ('failed')
end.
