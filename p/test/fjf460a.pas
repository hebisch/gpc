program fjf460a;

var
  s : String (42);

begin
  WriteStr (s, EQ (ParamStr (2), ''), 'x');
  if s = 'Truex' then WriteLn ('OK') else WriteLn ('failed')
end.
