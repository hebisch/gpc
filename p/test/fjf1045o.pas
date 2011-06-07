program fjf1045o (Output);

type
  s4 = String (4);
  s5 = String (5);
  p5 = ^s5;

var
  CalledF, CalledG: Boolean value False;

function f: s4;
begin
  if CalledF then WriteLn ('failed f');
  CalledF := True;
  f := 'OK'
end;

function g = r: p5;
begin
  if CalledG then WriteLn ('failed g');
  CalledG := True;
  New (r);
  r^ := 'OK'
end;

procedure p (a, b: String);
begin
  if a = b then WriteLn (a) else WriteLn ('failed')
end;

{$extended-pascal}

begin
  p (f, g^)
end.
