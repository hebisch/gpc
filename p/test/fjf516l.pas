program fjf516l;

type
  TString = String (10);

function s: TString;
begin
  s := ''
end;

begin
  if s >= '' then;  { WARN }
  WriteLn ('failed')
end.
