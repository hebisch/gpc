program fjf426g;

{$no-extended-SYNTAX}

begin
  {$ifopt X+}
  WriteLn ('failed')
  {$else}
  WriteLn ('OK')
  {$endif}
end.
