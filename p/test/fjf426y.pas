program fjf426y;

{$borland-pascal}
{$W+}
{$W warnings}

begin
  {$ifopt W+}
  WriteLn ('OK')
  {$else}
  WriteLn ('failed')
  {$endif}
end.
