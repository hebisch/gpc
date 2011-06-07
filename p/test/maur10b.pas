program Maur10b;

type
  TString = String (42);

var
  s: TString;

function f: TString;
begin
  f := 'OK'
end;

begin
  ReadStr (f, s);
  WriteLn (s)
end.
