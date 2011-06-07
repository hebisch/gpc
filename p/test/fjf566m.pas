program fjf566m;

begin
  if Abs (1.4 ** 2.6 ** 0.8 { WRONG } - 2.013475) < 0.00001 then WriteLn ('failed 1') else WriteLn ('failed 2')
end.
