program fjf426s;

{$W no-mixed-comments}

begin
  {$ifopt W no-mixed-comments}
  WriteLn ('OK')
  {$else}
  WriteLn ('failed')
  {$endif}
end.
