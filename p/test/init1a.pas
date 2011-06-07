program init1a(output);
type tarr = array [0..2] of -5 .. 5;
var
  s : tarr value [1: (-1) ; case 0 of [0: 1]]; { WRONG }

begin
  if s[1] = -1 then writeln('failed')
end.
