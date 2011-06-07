program fjf878;

type
  x (n: Integer) = Integer;
  c = Integer;
  g = ^c .. ^d;
  b = ^c;
  f = ^x;
  a = (^c) .. ^d;
  e = (^x) .. ^y;
  d = ^x .. ^z;

var
  k: b;
  q: f;

begin
  if (Low (g) = #3) and (High (g) = #4)
     and (Low (k^) = Low (Integer)) and (High (k^) = MaxInt)
     and (Low (q^) = Low (Integer)) and (High (q^) = MaxInt)
     and (Low (q^.n) = Low (Integer)) and (High (q^.n) = MaxInt)
     and (Low (a) = #3) and (High (a) = #4)
     and (Low (e) = #24) and (High (e) = #25)
     and (Low (d) = #24) and (High (d) = #26) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
