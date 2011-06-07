program fjf957b;

type
  t = array ['A' .. 'A'] of Char;

var a, b: t;

begin
  a := 'O';
  b := 'K';
  WriteLn (a + b)
end.
