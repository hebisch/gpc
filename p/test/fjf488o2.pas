program fjf488o2;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if Index (b, a) = 3 then WriteLn ('OK') else WriteLn ('failed')
end.
