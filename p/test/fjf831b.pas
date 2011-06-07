program fjf831b;

type
  t = record end;

procedure p;
var a: t;
begin
  with a do
    var a: t;  { WRONG }
end;

begin
end.
