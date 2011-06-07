program fjf460b;

var
  s: String (42);
  e: String (10) = '';

begin
  WriteStr (s, EQ (ParamStr (2), e), 'x');
  if s = 'Truex' then WriteLn ('OK') else WriteLn ('failed')
end.
