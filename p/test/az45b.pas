{ Changed the result type of f to avoid (yet another instance of the)
  `setlimit' issue. The change has no relevance to the actual issue
  that was tested here. -- Frank }

program az45b(output);
var x:boolean;
function f:Byte;
begin
  f:=1;
  x:=true
end;
begin
  x:=false;
  {$local W-} if 1 in [1,f] then {$endlocal}
    writeln('OK')  { f may or may not have been called,
                     cf. <20021220163118.GA4176@artax.karlin.mff.cuni.cz> }
  else
    writeln('failed')
end.
