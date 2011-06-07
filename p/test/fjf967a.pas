program fjf967a;

var
  a: record
    x: packed array [1 .. 10] of Integer
  end = [x: [otherwise 2]];

begin
  if a.x[5] = 2 then WriteLn ('OK') else WriteLn ('failed')
end.
