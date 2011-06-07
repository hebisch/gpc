program fjf957a;

type
  t = array ['A' .. 'Z'] of Char;

var
  a, b: t;

begin
  b := 'OK';
  a := b;
  WriteLn (a['A' .. 'B'])
end.
