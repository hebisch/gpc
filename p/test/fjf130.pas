program fjf130;
type t(d:integer)=array[1..d] of integer;
     x=t(6);
var a:^t;
    b:^x;
begin
  New(a,6);
  b:=a;  { WRONG }
  writeln('Failed: ', b^.d)
end.
