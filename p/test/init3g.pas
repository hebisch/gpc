program init3g(output);
type tset = set of -5 .. 5;
     trset = record s: set of -5 .. 5; end;
const
  s1 = tset[-1];
  s2 = tset[((-1))];
  rs = trset[[((-1))]];

begin
  if (-1 in s1) and (-1 in s2) and (-1 in rs.s) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end
.
