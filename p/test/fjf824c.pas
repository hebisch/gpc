program fjf824c;

uses GPC;

var
  s: TString;

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
function f: TString; attribute (iocritical);
var t: Text;
begin
  Reset (t);
  f := 'failed'
end;
{$I+}

begin
  AtExit (CheckError);
  s := f;
  InOutRes := 0;
  WriteLn ('failed')
end.
