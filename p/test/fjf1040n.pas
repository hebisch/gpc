module fjf1040n;

export fjf1040n = all;

const
  b = 17 + 25;
  c = 'O' + 'K';
  d = [4 .. 6, 9, 11];
  e = Pointer (100 + SizeOf (Integer));

type
  a = Integer value 42;

function f (b: Integer) = c: Char; external name 'foo';

end;

end.
