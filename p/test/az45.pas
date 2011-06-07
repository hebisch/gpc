{ Changed the result type of f to avoid (yet another instance of the)
  `setlimit' issue. The change has no relevance to the actual issue
  that was tested here. -- Frank }

program az45(output);
var x:boolean;
function f:Byte;
begin
  f:=1;
  x:=true
end;
begin
  x:=false;
  if 1 in [1,f] then  { WARN }
    if x
      then writeln('failed 1')
      else writeln('failed 2')
end.
