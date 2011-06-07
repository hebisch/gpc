program fjf426c;

{$X+}

begin
  {$ifopt X-}
  WriteLn ('failed')
  {$else}
  WriteLn ('OK')
  {$endif}
end.
