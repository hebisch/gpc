program fjf513;

const
  x: array [1 .. 2, 1 .. 4] of Char = ('ABCD', 'EOKF');

begin
  WriteLn (x[2, 2 .. 3])
end.
