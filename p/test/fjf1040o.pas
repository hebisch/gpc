module fjf1040o;

export fjf1040o = all;

type
  a = Integer value 42;
  p = ^Integer;

function f (b: Integer) = c: Char; external name 'foo';

const
  b = 42;
  c = 'OK';
  d = ([-2 .. 200] - [7 .. 8]) * [4 .. 12] >< [10, 12];
  {$pointer-arithmetic}
  e = Pointer (Succ (p (200 - 100)));

end;

end.
