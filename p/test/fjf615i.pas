program fjf615i;

procedure bar (const a: Integer);

  procedure foo (var a: Integer);
  begin
  end;

begin
  foo (a);  { WARN }
  WriteLn ('failed')
end;

begin
  bar (42)
end.
