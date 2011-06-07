program fjf115;
type y(b:integer)=array[1..b] of integer;
     x=y;
var a:x(1000);
begin
 if a.b=1000 then WriteLn('OK') else WriteLn('failed ', a.b)
end.
