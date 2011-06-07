program fjf837d;

var i: Integer;

procedure p (var i: Integer);
begin
end;

begin
  for i in [3, 4] do
    p (i)  { WRONG }
end.
