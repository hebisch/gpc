{$mac-pascal}

program fjf988k;

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
