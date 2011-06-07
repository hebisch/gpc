{ Qualified identifiers }

program kurzw1;

uses kurzw1u;

procedure foo (i : integer);
begin
  if i = 42 then WriteLn ('OK') else WriteLn ('failed')
end;

procedure bar;
begin
  foo (42)
end;

begin
  bar
end.
