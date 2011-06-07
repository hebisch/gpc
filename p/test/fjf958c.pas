program fjf958c;

type
  t = String (10);

var
  s: String (10);
  Called: Boolean = False;

function f: t;
begin
  if Called then
    begin
      WriteLn ('failed');
      Halt
    end;
  Called := True;
  f := ''
end;

begin
  ReadStr (f, s);
  WriteLn ('OK')
end.
