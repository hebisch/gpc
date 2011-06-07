program fjf566l;

begin
  if Abs (2 ** 2.3 pow 4 { WRONG } - 588.13356) < 0.0001 then WriteLn ('failed 1') else WriteLn ('failed 2')
end.
