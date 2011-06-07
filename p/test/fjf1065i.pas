program fjf1065i;

type
  Foo = Integer;

Uses GPC;

begin
  if MaxVarSize > 0 then WriteLn ('OK') else WriteLn ('failed')
end.
