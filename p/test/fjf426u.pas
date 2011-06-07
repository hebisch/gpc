program fjf426u;

{$W-,F+,W+}

begin
  {$ifopt F+}
  WriteLn ('OK')
  {$else}
  WriteLn ('failed')
  {$endif}
end.
