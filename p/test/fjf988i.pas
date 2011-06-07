{$no-nonlocal-exit}

program fjf988i;

procedure bar;

  procedure foo;
  begin
    Exit (bar)  { WRONG }
  end;

begin
end;

begin
end.
