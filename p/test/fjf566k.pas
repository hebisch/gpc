program fjf566k;

begin
  if Abs (2 pow 3 ** 4.2 { WRONG } - 6208.375) < 0.001 then WriteLn ('failed 1') else WriteLn ('failed 2')
end.
