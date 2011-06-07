program fjf821p;

type t = file of Integer;

procedure q (var f: t);
begin
end;

procedure p (var f: AnyFile);
begin
  q (f)  { WRONG }
end;

begin
end.
