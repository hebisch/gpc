program fjf386;

procedure baz;

  procedure foo (const s : String);
  begin
  end;

begin
  foo ('')
end;

procedure bar (const s : String);
begin
  WriteLn (s)
end;

begin
  bar ('OK')
end.
