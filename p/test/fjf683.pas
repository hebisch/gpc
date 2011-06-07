program fjf683;
var i: Integer = -300;
begin
  if i shr Word (5) = -10 then WriteLn ('OK') else WriteLn ('failed ', i shr Word (5))
end.
