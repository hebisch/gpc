{$no-exact-compare-strings}
program fjf498b8;

begin
  if NE (succ ('q'), pred ('s')) then WriteLn ('failed') else WriteLn ('OK')
end.
