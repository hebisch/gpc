{ FLAG -O0 }

program fjf603;

type
  TString = String (10);

procedure f (const s: String);
begin
end;

procedure qqq;
begin
end;

procedure p (s: String);
var
  a: TString;
  c: Integer;
begin
  a := s;
  if Length (a) > 0 then
    for c := 1 to 1 do
      if Copy (a, 1, 1) = '' then
        WriteLn ('x')
end;

procedure q;
var q: TString;
begin
  {$local W-} f (q) {$endlocal}
end;

begin
  WriteLn ('OK')
end.
