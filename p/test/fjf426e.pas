program fjf426e;

{$X+}

begin
  {$ifopt extended-syntax}
  WriteLn ('OK')
  {$else}
  WriteLn ('failed')
  {$endif}
end.
