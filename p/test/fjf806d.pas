program fjf806d;

type
  TString = String (10);

procedure p (const p: TString);
begin
  WriteLn (p)
end;

begin
  p ('OK')
end.
