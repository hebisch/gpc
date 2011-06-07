program fjf689;

type
  q = ^a;
  a = Integer;

procedure foo;
type
  p = ^a;
  a = Boolean;

var
  v: p;

begin
  New (v);
  v^ := True;
  if v^ then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  foo
end.
