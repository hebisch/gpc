program fjf426t;

begin
  {$ifopt foobar} { WRONG }
  {$endif}
  WriteLn ('failed')
end.
