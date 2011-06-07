program fjf1104d (Output);

procedure p;

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
end;

begin
  p
end.
