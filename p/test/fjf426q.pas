program fjf426q;

{$W mixed-comments}

begin
  {$ifopt W no-mixed-comments}
  WriteLn ('failed')
  {$else}
  WriteLn ('OK')
  {$endif}
end.
