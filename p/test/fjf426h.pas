program fjf426h;

{$no-extended-SYNTAX}

begin
  {$ifopt no-extended-syntax}
  WriteLn ('OK')
  {$else}
  WriteLn ('failed')
  {$endif}
end.
