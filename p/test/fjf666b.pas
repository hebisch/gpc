program fjf666b;

var
  i: LongInt = -42;
  v: LongBool;

begin
  v := LongBool (i);
  if Ord (v) + LongWord (41) = High (LongWord) then WriteLn ('OK') else WriteLn ('failed ', Ord (v), ' ', Ord (v) + LongWord (41))
end.
