program fjf426v;

{$W-,F+,W+}

begin
  {$ifopt F-}
  WriteLn ('failed')
  {$else}
  WriteLn ('OK')
  {$endif}
end.
