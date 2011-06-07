program fjf426r;

{$W no-mixed-comments}

begin
  {$ifopt W mixed-comments}
  WriteLn ('failed')
  {$else}
  WriteLn ('OK')
  {$endif}
end.
