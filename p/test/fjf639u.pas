program fjf639u;

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
  pt = ^t;
  t = object end;

  pu = ^u;
  u = object (t) end;

var
  v: pt;

begin
  AtExit (CheckError);
  v := New (pt);
  with v^ as u do
end.
