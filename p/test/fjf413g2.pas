program fjf413g2;

const
  Foo : (False) .. (True = True) = False = False;

begin
  if Foo then WriteLn ('OK') else WriteLn ('failed')
end.
