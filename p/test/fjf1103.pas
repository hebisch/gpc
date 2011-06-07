{ FLAG -W }

program fjf1103 (Output);

type
  TString = String (100);

function f: TString;
begin
  f := 'OK'
end;

var
  s: TString = f;

begin
  WriteLn (s)
end.

