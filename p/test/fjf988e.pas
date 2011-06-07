program fjf988e;

procedure bar;

  procedure foo;
  begin
    Write ('O');
    Exit (foo);
    WriteLn ('failed')
  end;

begin
  foo;
  Write ('K')
end;

begin
  bar;
  WriteLn
end.
