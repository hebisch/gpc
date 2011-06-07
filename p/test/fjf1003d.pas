program fjf1003d (Output);

type
  ta = array [1 .. 3] of Char;

const
  a = ta['N'; 'O'; 'P'];

type
  t (n: Integer) = array ['K' .. a[n]] of Integer;

var
  i: Integer = 2;
  v: t (i);

begin
  WriteLn (High (v), Low (v))
end.
