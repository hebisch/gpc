program fjf1102 (Output);

var
  a: ByteBool;
  b: WordBool;
  c: LongBool;
  d, e, f: Boolean;

begin
  a := ByteBool (42);
  b := WordBool (1000);
  c := LongBool ($10000);
  d := a;
  e := b;
  f := c;
  if (Ord (d) = 1) and (Ord (e) = 1) and (Ord (f) = 1) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', Ord (d), Ord (e), Ord (f))
end.

