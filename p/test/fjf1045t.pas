program fjf1045t (Output);

type
  t (n: Integer) = array [1 .. n] of Integer;
  t3 = t (3);
  pt = ^t;

var
  CalledF, CalledG: Boolean value False;

function f: t3;
begin
  if CalledF then WriteLn ('failed f');
  CalledF := True;
  f := t3[4; 5; 6]
end;

function g = r: pt;
begin
  if CalledG then WriteLn ('failed g');
  CalledG := True;
  New (r, 3);
  r^ := t3[7; 8; 9]
end;

procedure p (a, b: t);
begin
  if (a.n = 3) and (a[1] = 4) and (a[2] = 5) and (a[3] = 6) and
     (b.n = 3) and (b[1] = 7) and (b[2] = 8) and (b[3] = 9) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', a.n, ' ', a[1], ' ', a[2], ' ', a[3], ' ',
                        b.n, ' ', b[1], ' ', b[2], ' ', b[3])
end;

{$extended-pascal}

begin
  p (f, g^)
end.
