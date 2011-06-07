program fjf679;

type
  TString = String (100);

const
  c: TString = '';

procedure p (const s: String);
begin
  WriteLn (s)
end;

function f (const s: String): TString;
begin
  f := s
end;

begin
  p (f ('OK'))
end.
