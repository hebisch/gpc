program fjf951b;

type
  a = set of (c, d);

var
  b: set of (e, f);

procedure p (q: a);
begin
end;

begin
  p (b)  { WRONG }
end.
