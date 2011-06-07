program fjf507c;

const b: array [-4 .. 5] of Char = 'DJOKWJEHDJ';

begin
  var a: String(8) = b[-3 .. 4];
  WriteLn (a[2 .. 3])
end.
