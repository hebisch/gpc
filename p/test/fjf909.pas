program fjf909;

var
  a, b, c, d: Integer;

begin
    Val ('invalid', a, b);
    Val ('123456789012345invalid', c, d);
    if (b = 1) and (d = 16) then WriteLn ('OK') else WriteLn ('failed ', b, ' ', d)
end.
