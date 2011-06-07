program fjf958a;

type
  t = ^String;

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
  f := @s
end;

begin
  ReadStr (s, f^);
  WriteLn ('OK')
end.
