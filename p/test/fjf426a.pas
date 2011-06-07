program fjf426a;

{$X+}

begin
  {$ifopt X+}
  WriteLn ('OK')
  {$else}
  WriteLn ('failed')
  {$endif}
end.
