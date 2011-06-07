program fjf639j;

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
  t = abstract object end;
  u = abstract object (t) end;
  pv = ^v; v = object (t) end;
  pw = ^w; w = object (u) end;

var
  x: ^t;

begin
  AtExit (CheckError);
  x := New (pv);
  with x^ as u do
end.
