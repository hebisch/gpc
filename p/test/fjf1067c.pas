program fjf1067c (Output);

uses GPC;

procedure p;
begin
  if GPC.MaxVarSize > 1 then WriteLn ('OK') else WriteLn ('failed')
end;

const
  MaxVarSize = 0;

begin
  p
end.
