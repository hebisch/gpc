program fjf488p3;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if Pos (b, a) = 0 then WriteLn ('OK') else WriteLn ('failed')
end.
