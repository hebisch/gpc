{ FLAG --no-assertions }

program fjf665r;

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
  AtExit (CheckError);
  {$C+}
  Assert (False)
end.
