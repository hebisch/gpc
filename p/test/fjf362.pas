program fjf362;

procedure bar (const a : String);

  procedure baz (const b : String);
  begin
    WriteLn (b)
  end;

begin
  baz ('OK')
end;

begin
  bar ('')
end.
