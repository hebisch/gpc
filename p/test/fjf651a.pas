program fjf651a;

type
  PString = ^String;

var
  s: String (20) = '-12345 42';
  Called: Boolean = False;

function f: PString;
begin
  if Called then
    begin
      WriteLn ('failed 1');
      Halt
    end;
  Called := True;
  f := @s
end;

var
  a, b: Integer;

begin
  ReadStr (f^, a, b);
  if Called and (a = -12345) and (b = 42) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', Called, ' ', a, ' ', b)
end.
