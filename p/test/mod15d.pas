program mod15d;
const x = 'OK';
procedure p1;
 import e1 in 'mod15m.pas';
begin
 x := 1;
 f(2)
end;
begin
  p1;
  e1.x := 3; { WRONG }
end
.
