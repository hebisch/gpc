program fjf430f;

begin
  {$local X+} { WRONG: unmatched `$local' }
  WriteLn ('failed')
end.
