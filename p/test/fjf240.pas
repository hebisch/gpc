{ Qualified identifiers }

program fjf240;

uses fjf240u;

procedure baz;

  procedure bar;
  begin
    writeln ('OK')
  end;

begin
  bar
end;

begin
  baz
end.
