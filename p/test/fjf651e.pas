program fjf651e;

type
  TString = String (20);

var
  Called: Boolean = False;

function f: TString;
begin
  if Called then
    begin
      WriteLn ('failed 1');
      Halt
    end;
  Called := True;
  f := '-12345 42'
end;

var
  a, b: Integer;

begin
  ReadStr (f, a, b);
  if Called and (a = -12345) and (b = 42) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', Called, ' ', a, ' ', b)
end.
