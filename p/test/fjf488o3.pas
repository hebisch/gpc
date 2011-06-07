program fjf488o3;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if Index (a, b) = 0 then WriteLn ('OK') else WriteLn ('failed')
end.
