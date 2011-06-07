program fjf190;

procedure p(c:cstring);
begin
  writeln(cstring2string(c))
end;

procedure q(const s:string);
begin
  p(s)
end;

begin
  q('OK')
end.
