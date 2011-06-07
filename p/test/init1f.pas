program init1f(output);
type tarr = array [0..1] of -5 .. 5;
var
  s : tarr value [1: [-1]]; { WRONG }

begin
  if s[1] = -1 then writeln ('failed')
end.
