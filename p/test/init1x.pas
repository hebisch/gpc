program init1x(output);
type tvr(s : integer) = record i : integer; case s of
                    0..10:    (j : integer);
                    otherwise (r : record c : char end)
           end;
var v : tvr(5) value [i:1; case 8 of [j:3]];
begin
  if (v.s = 5) and (v.i = 1) and (v.j = 3) then WriteLn ('OK') else WriteLn ('failed')
end
.
