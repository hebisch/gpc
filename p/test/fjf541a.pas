program fjf541a;

var
  i: LongInt = -17;
  b: ShortCard = 555;

begin
  {$W-}
  if (Trunc (i) = -17) and (Trunc (b) = 555) and (Trunc (42) = 42) and
     (Round (i) = -17) and (Round (b) = 555) and (Round (42) = 42) then
  {$W+}
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
