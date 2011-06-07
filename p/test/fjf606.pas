program fjf606;

type
  t = MedCard;

var
  a, b: t;

begin
  b := 0;
  for a := 0 to b do  { spurious warning }
    WriteLn ('OK')
end.
