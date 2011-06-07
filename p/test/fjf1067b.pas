program fjf1067b (Output);

import GPC qualified;

const
  MaxVarSize = 0;

procedure p;
begin
  if GPC.MaxVarSize > 1 then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  p
end.
