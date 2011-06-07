program fjf1003c (Output);

const
  a = 'NOP';

type
  t (n: Integer) = array ['K' .. a[n]] of Integer;

var
  i: Integer = 2;
  v: t (i);

begin
  WriteLn (High (v), Low (v))
end.
