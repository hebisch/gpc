program fjf530;

procedure foo (const a: LongInt);
begin
  if a = 42 then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  foo (42)
end.
