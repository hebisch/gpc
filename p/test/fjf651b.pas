program fjf651b;

type
  PString = ^String;

var
  s: String (20) = '42';
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
  Val (f^, a, b);
  if Called and (a = 42) and (b = 0) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', Called, ' ', a, ' ', b)
end.
