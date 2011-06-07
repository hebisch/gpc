program fjf488p2;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if Pos (a, b) = 3 then WriteLn ('OK') else WriteLn ('failed')
end.
