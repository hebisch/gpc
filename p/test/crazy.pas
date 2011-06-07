program crazy;
var i1 : integer value 0;
function f(i: integer):integer;
begin
  f := i + i1;
end;
type s(i: integer) = array[0..f(i)] of char;  { WRONG }

procedure foo;
var vs : s(5);
begin
end;
begin
  i1 := 5;
  foo
end
.
