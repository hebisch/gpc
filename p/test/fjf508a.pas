{ FLAG --uses=md5,trap }

program fjf508a;
begin
  if (SizeOf (TMD5) = 16) and (TrappedExitCode = 0) then WriteLn ('OK') else WriteLn ('failed')
end.
