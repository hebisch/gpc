program fjf1023b;

procedure p (s: String);
var v: type of s;
begin
  if v.Capacity = 11 then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  p ('           ')
end.
