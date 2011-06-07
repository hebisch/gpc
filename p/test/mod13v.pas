module mod13v;
export mod13v=(v2, f2);
var v2 : integer;
function f2: boolean;
end;
import mod13v1;
function f2: boolean;
begin
  f2:= (not f1) or (v1<>11)
end;
to begin do
  v2:=2;
end.
