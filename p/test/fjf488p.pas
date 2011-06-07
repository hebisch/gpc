program fjf488p;

var a : char = 'x';
    b : char = 'x';

begin
  if Pos (a, b) = 1 then WriteLn ('OK') else WriteLn ('failed')
end.
