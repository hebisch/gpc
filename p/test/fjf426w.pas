program fjf426w;

{$W-}
{$W warnings}

begin
  {$ifopt W+}
  WriteLn ('OK')
  {$else}
  WriteLn ('failed')
  {$endif}
end.
