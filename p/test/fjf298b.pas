program fjf298b;

procedure x (var s : string);
begin
  writeln (s)
end;

begin
  x (copy ('failed', 1)) { WRONG }
end.
