program fjf831c;

type
  t = record end;

procedure p;
var a: t;
begin
  var a: t;  { WRONG }
  with a do
    begin
      var a: t;  { WRONG }
    end
end;

begin
end.
