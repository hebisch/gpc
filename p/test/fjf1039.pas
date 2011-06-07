{ FLAG -g0 }

program fjf1039 (Output);

type
  a = ^Byte attribute (aligned = 64);

begin
  if AlignOf (a) = 64 then WriteLn ('OK') else WriteLn ('failed ', AlignOf (a))
end.
