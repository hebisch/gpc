program fjf824e;

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

{$I-}
procedure p (i: Integer); attribute (iocritical);
var t: Text;
begin
  Reset (t)
end;
{$I+}

begin
  AtExit (CheckError);
  p (42);
  InOutRes := 0;
  WriteLn ('failed')
end.
