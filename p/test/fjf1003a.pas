program fjf1003a (Output);

const
  a = 'NOP';

type
  t (n: Integer) = array ['K' .. a[n]] of Integer;

var
  v: t (2);

begin
  WriteLn (High (v), Low (v))
end.
