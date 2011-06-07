{$borland-pascal}

program fjf535c;
begin
  {$ifopt gnu-pascal}
  WriteLn ('failed 1');
  Halt;
  {$endif}
  {$ifopt borland-pascal}
  WriteLn ('OK')
  {$else}
  Writeln ('failed 2')
  {$endif}
end.
