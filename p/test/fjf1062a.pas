{$nonlocal-exit}

program fjf1062a (Output);

procedure Near;

  procedure p;
  begin
    Exit (Near);
    WriteLn ('failed 1')
  end;
  
begin
  p;
  WriteLn ('failed 2')
end;

begin
  Near;
  WriteLn ('OK')
end.
