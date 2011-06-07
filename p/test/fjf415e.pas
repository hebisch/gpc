program fjf415e;
var i : Real;
begin
  i := 0.0;
  repeat i := {$W-} 4.e1until {$W+} True;
  if i = 40 then WriteLn ('OK') else WriteLn ('failed')
end.
