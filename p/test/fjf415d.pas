program fjf415d;
var i : Real;
begin
  i := 0.0;
  repeat i := {$W-} 4.5e1until {$W+} True;
  if i = 45 then WriteLn ('OK') else WriteLn ('failed')
end.
