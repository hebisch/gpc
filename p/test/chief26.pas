program chief26;

type t = procedure (const s : integer);

procedure foo (const s : integer);
begin
  if s = 43 then writeln ('OK') else writeln ('failed')
end;

procedure bar (f : t);
begin
  f (43)
end;

begin
  bar (foo)
end.
