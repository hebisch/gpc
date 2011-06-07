program init1e(output);
type tarr = array [0..1] of -5 .. 5;
var
  s : tarr value [0..1: [0..1:-1]]; { WRONG }

begin
  if s[1] = -1 then writeln ('failed')
end.
