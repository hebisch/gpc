program fjf268c;

var
  s : string (10) = '';

procedure foo (const s : string);
begin
  insert ('failed', s, 1) { WRONG }
end;

begin
  foo (s);
  writeln (s)
end.
