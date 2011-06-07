{$no-exact-compare-strings}
program fjf498a8;

begin
  if EQ (succ ('q'), pred ('s')) then WriteLn ('OK') else WriteLn ('failed')
end.
