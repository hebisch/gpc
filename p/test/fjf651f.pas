program fjf651f;

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
  f := '42'
end;

var
  a, b: Integer;

begin
  Val (f, a, b);
  if Called and (a = 42) and (b = 0) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', Called, ' ', a, ' ', b)
end.
