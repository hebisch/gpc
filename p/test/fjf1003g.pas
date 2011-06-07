{ FLAG -O0 }

program fjf1003g (Output);

const
  a = 'NOP';

type
  t (n: Integer) = array ['K' .. a[n]] of Integer;

var
  v: t (4);  { WRONG }

begin
end.
