{ FLAG --uses=md5 --uses=trap }

program fjf508b;
begin
  if (SizeOf (TMD5) = 16) and (TrappedExitCode = 0) then WriteLn ('OK') else WriteLn ('failed')
end.
