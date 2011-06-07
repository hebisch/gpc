{ FLAG --borland-pascal }

program fjf724a;

procedure foo;
begin
  {$gnu-pascal}   { GPC (used to) place new built-in definitions caused
                    by a compiler directive at the current "binding level",
                    rather than the global one. }
end;

var
  a: Cardinal = 42;

begin
  if a = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
