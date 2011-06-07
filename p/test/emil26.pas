program prog;
type a=0..5;
var  c:a;
procedure foo(function bar:integer);
begin
end;
function baz:a;
begin
  baz := c
end;
begin
  foo(baz)  { WRONG }
end
.
