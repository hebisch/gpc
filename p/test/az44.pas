{ Changed the result type of f to avoid (yet another instance of the)
  `setlimit' issue. The change has no relevance to the actual bug
  that was tested here. -- Frank }

program az44(output);
var x:integer;
function f:Byte;
begin
  f:=x;
  x:=2
end;
begin
  x:=1;
  if [1]=[f]
    then writeln('OK')
    else writeln('failed')
end.
