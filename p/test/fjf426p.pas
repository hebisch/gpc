program fjf426p;

{$W mixed-comments}

begin
  {$ifopt W mixed-comments}
  WriteLn ('OK')
  {$else}
  WriteLn ('failed')
  {$endif}
end.
