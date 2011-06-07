program fjf426d;

{$X-}

begin
  {$ifopt X-}
  WriteLn ('OK')
  {$else}
  WriteLn ('failed')
  {$endif}
end.
