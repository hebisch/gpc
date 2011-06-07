program fjf963a;

type
  TString = String (20);

var
  Called: Boolean = False;

function f: Integer;
begin
  if Called then
    begin
      WriteLn ('failed 1');
      Halt
    end;
  Called := True;
  f := 42
end;

var
  a: Integer;

begin
  a := Sqr (f);
  if Called and (a = 1764) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', Called, ' ', a)
end.
