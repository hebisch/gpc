program fjf115a(output);
{ FLAG --extended-pascal }
type y(b:integer)=array[1..b] of integer;
     x=y;  { WRONG }
var a:x(1000);
begin
 if a.b=1000 then writeln('failed') else writeln('failed 2')
end.
