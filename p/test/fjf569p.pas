program fjf569p;

procedure foo (const a: LongInt);
begin
  if a = 1 shl 56 then WriteLn ('OK') else WriteLn ('failed')
end;

var
  a: procedure (const s: LongInt) = foo;

begin
  a (4 shl 54)
end.
