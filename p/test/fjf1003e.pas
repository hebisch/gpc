program fjf1003e (Output);

const
  a = 'NOP';

type
  t (n: Integer) = array ['K' .. a[n]] of Integer;

var
  v: t (4);  { WRONG }

begin
end.
