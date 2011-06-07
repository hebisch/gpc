program fjf821o;

procedure q (var f: file);
begin
end;

procedure p (var f: AnyFile);
begin
  q (f)  { WRONG }
end;

begin
end.
