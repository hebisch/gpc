program fjf1067d (Output);

uses GPC;

const
  MaxVarSize = 0;

procedure p;
begin
  if GPC.MaxVarSize > 1 then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  p
end.
