program init1d(output);
type ind = (i0, i1, i2);
     tarr = array [0..2] of -5 .. 5;
var
  s : tarr value [i0..i2: (-1)]; { WRONG }

begin
  if s[i1] = -1 then writeln ('failed')
end.
