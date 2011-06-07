program fjf488p4;

var a : string (10) = 'wx';
    b : string (10) = 'vwxy';

begin
  if Pos (a, b) = 2 then WriteLn ('OK') else WriteLn ('failed')
end.
