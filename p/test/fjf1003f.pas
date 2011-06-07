program fjf1003f (Output);

type
  ta = array [1 .. 3] of Char;

const
  a = ta['N'; 'O'; 'P'];

type
  t (n: Integer) = array ['K' .. a[n]] of Integer;

var
  v: t (4);  { WRONG }

begin
end.
