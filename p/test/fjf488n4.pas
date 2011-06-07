program fjf488n4;

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

var
  a : String (10) = 'xyOK';

begin
  AtExit (CheckError);
  WriteLn (SubStr (a, 3, 2000))
end.
