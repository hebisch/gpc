program matt1;

var
  ds : ShortReal = 2;
  dr : Real = 2;
  dl : LongReal = 2;

begin
  ds := 0.5 / ds;
  dr := 0.5 / dr;
  dl := 0.5 / dl;
  if (ds = 0.25) and (dr = 0.25) and (dl = 0.25) then WriteLn ('OK') else WriteLn ('failed')
end.
