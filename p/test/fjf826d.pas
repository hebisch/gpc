program fjf826d;

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

type
  u = object (t)
    procedure q;
  end;

procedure u.q;
begin
  p
end;

var
  v: u;

begin
  AtExit (CheckError);
  v.q;
  InOutRes := 0
end.
