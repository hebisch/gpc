program fjf415f;
var i : Real;
begin
  i := 0.0;
  repeat i := {$W-} 4.euntil {$W+} true;
  if i = 4 then WriteLn ('OK') else WriteLn ('failed')
end.
