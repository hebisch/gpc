program fjf641l;

begin
  if Abs (Arg (-42) - Pi) < 1e-6 then WriteLn ('OK') else WriteLn ('failed')
end.
