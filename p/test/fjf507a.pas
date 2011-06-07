program fjf507a;

var
  a : array [1 .. 10] of Char = 'FJSDUEOKDJ';

begin
  var s : String (2) = a [7 .. 8];  { works with an assignment statement }
  WriteLn (s)
end.
