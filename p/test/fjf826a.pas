program fjf826a;

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

type
  t = object
    procedure p; attribute (iocritical);
  end;

{$I-}
procedure t.p;
var t: Text;
begin
  Reset (t)
end;
{$I+}

var
  v: t;

begin
  AtExit (CheckError);
  v.p;
  InOutRes := 0
end.
