{$W parentheses}

program fjf848e;
var a, b: Boolean = False;
begin
  if a = not b then WriteLn ('failed') else WriteLn ('OK')  { harmless, no confusion }
end.
