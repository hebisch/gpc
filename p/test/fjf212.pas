program fjf212;

procedure foo (const a : String);

  procedure bar (const a : String);
  begin
    writeln (a)
  end;

begin
  write (a);
  bar ('K')
end;

begin
  foo ('O')
end.
