{ Nitpick BP compatibility ... }

program fjf950;

type
  a = (b);

var
  c, d: a;

begin
  if @c <> @d then WriteLn ('OK') else WriteLn ('failed')
end.
