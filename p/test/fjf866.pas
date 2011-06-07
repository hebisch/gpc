program fjf866;

uses fjf866a;

procedure bar;
const a: Integer = 1;
begin
  foo;
  if a = 1 then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  bar
end.
