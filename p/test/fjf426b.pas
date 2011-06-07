program fjf426b;

{$X-}

begin
  {$ifopt X+}
  WriteLn ('failed')
  {$else}
  WriteLn ('OK')
  {$endif}
end.
