program fjf1058 (Output);
uses fjf1058u;
type t = fjf1058u.a .. 10;  { fails }
begin
  if Low (t) = 1 then WriteLn ('OK') else WriteLn ('failed')
end.
