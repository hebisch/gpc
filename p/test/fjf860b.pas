program fjf860b;

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

var
  a: procedure attribute (iocritical);

begin
  AtExit (CheckError);
  a := p;
  a;
  InOutRes := 0
end.
