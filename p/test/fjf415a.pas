program fjf415a;
var i : Real;
begin
  i := 0.0;
  repeat i := {$W-} 4until {$W+} True;
  if i = 4 then WriteLn ('OK') else WriteLn ('failed')
end.
