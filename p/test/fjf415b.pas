program fjf415b;
var i : Real;
begin
  i := 0.0;
  repeat i := {$W-} 4.5until {$W+} True;
  if i = 4.5 then WriteLn ('OK') else WriteLn ('failed')
end.
