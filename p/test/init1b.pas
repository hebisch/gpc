program init1b(output);
type tarr = array [0..2] of -5 .. 5;
var
  s : tarr value [0..2: (-1) ; 1: 1]; { WRONG }

begin
  if s[1] = -1 then writeln ('failed')
end.
