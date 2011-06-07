{$nonlocal-exit}

program fjf1062b (Output);

procedure Object;

  procedure p;
  begin
    Exit (Object);
    WriteLn ('failed 1')
  end;
  
begin
  p;
  WriteLn ('failed 2')
end;

begin
  Object;
  WriteLn ('OK')
end.
