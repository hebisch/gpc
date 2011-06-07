program init1c(output);
type ind = (i0, i1, i2);
     tarr = array [i0..i2] of -5 .. 5;
var
  s : tarr value [0..2: (-1)]; { WRONG }

begin
  if s[i1] = -1 then writeln ('failed')
end.
