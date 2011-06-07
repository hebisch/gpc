program fjf821n;

procedure q (var f: Text);
begin
end;

procedure p (var f: AnyFile);
begin
  q (f)  { WRONG }
end;

begin
end.
