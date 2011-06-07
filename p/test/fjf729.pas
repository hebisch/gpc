program fjf729;

type
  a = (b, c, d, e, f, g);
  h = c .. f;

const
  i = h (d);

type
  j = i .. e;

const
  k = j (e);
  l = h (f);

type
  m = k .. l;

begin
  if (Low (m) = Succ (i)) and (High (m) = Succ (k)) then WriteLn ('OK') else WriteLn ('failed')
end.
