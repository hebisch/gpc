program fjf665i;

uses GPC;

procedure CheckError;
begin
  if ErrorAddr = nil then
    WriteLn ('failed')
  else
    begin
      ErrorAddr := nil;
      ErrorMessageString := '';
      WriteLn ('OK')
    end
end;

begin
  Assert (True);
  {$local no-assertions} Assert (False); {$endlocal}
  AtExit (CheckError);
  Assert (False)
end.
