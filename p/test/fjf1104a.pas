program fjf1104a (Output);

type
  TString = String (100);

function f: TString;
begin
  f := 'OK this is not'
end;

var
  s: String (2) = f;

begin
  WriteLn (s)
end.
