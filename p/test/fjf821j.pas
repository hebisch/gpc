program fjf821j;

procedure p (var f: AnyFile);
begin
  Move (f^, null, 0)  { WRONG }
end;

begin
end.
