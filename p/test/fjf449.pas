{ When fixed, change Schema1Demo in programming.texi accordingly! }

program fjf449;

type
  PositiveInteger = 1 .. MaxInt;
  Matrix (n, m : PositiveInteger) = array [1 .. n, 1 .. m] of Integer;

begin
  WriteLn ('OK')
end.
