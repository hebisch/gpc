program fjf426f;

{$X+}

begin
  {$ifopt NO-extended-syntax}
  WriteLn ('failed')
  {$else}
  WriteLn ('OK')
  {$endif}
end.
