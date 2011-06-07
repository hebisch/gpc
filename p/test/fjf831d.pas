program fjf831d;

type
  t = record end;

procedure p;
var a: t;
begin
  with a do
    begin
      var a: t;  { WRONG }
    end
end;

begin
end.
