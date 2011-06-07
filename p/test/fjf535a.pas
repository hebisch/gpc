program fjf535a;
begin
  {$ifopt borland-pascal}
  WriteLn ('failed 1');
  Halt;
  {$endif}
  {$ifopt gnu-pascal}
  WriteLn ('OK')
  {$else}
  Writeln ('failed 2')
  {$endif}
end.
