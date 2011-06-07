{$nonlocal-exit}

program fjf988f;

procedure bar;

  procedure foo;
  begin
    Write ('O');
    Exit (bar);
    WriteLn ('failed')
  end;

begin
  foo;
  WriteLn ('failed')
end;

begin
  bar;
  WriteLn ('K')
end.
