program fjf824a;

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
procedure p; attribute (iocritical);
var t: Text;
begin
  Reset (t)
end;
{$I+}

begin
  AtExit (CheckError);
  p;
  InOutRes := 0
end.
