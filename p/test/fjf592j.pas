program fjf592j;

type
  TFoo = 'a' .. 'm';
  TBar = 'a' .. 'n';

procedure Bar (var b: TBar);
begin
end;

var
  a: TFoo;

begin
  Bar (a);  { WRONG }
  WriteLn ('failed')
end.
