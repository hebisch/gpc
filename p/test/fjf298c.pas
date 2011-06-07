program fjf298c;

procedure x (var s : string);
begin
  writeln ('failed (', s, ')')
end;

begin
  x (ParamStr (0)) { WRONG }
end.
