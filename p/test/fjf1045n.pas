program fjf1045n (Output);

type
  t (n: Integer) = Integer;
  t2 = t (2);

var
  CalledF, CalledG: Boolean value False;

function f: t2;
begin
  if CalledF then WriteLn ('failed f');
  CalledF := True;
  f := 42
end;

function g: t2;
begin
  if CalledG then WriteLn ('failed g');
  CalledG := True;
  g := 17
end;

procedure p (a, b: t);
begin
  if (a = 42) and (b = 17) then WriteLn ('OK') else WriteLn ('failed')
end;

{$extended-pascal}

begin
  p (f, g)
end.
