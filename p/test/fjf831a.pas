program fjf831a;

type
  t = record end;

procedure p;
var a: t;
begin
  var a: t;  { WRONG }
  with a do
    var a: t;  { WRONG }
end;

begin
end.
