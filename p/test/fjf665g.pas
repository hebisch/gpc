{ FLAG --no-assertions }

{$assertions}

program fjf665g;

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
  Assert (False)
end.
