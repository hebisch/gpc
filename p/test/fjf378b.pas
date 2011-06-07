program fjf378b;

type
  e = (a, b, c);
  t = array [b .. High (e)] of Integer;

var
  v : t;

begin
  if (Ord (Low (v)) = 1) and (Ord (High (v)) = 2)
    then WriteLn ('OK')
    else WriteLn ('failed')
end.
