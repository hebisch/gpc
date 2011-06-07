{ COMPILE-CMD: emil4.cmp }

program EPRealConstants (Output);

uses GPC;

var
  r, s: Real; attribute (volatile);
  OK: Boolean Value True;

procedure Bomb (i: Integer);
begin
  WriteLn ('Failed ', i : 2, ': ', r, ', ', s);
  OK := False
end;

begin
  s := 0;
  r := MinReal;
  if IsNotANumber (r)   then Bomb (1);
  if IsInfinity (r)     then Bomb (2);
  if r <= 0             then Bomb (3);
  s := r * (1 + EpsReal);
  if s <= r             then Bomb (41);
  r := r / 2;
  s := r * (1 + EpsReal);
{
  if s > r              then Bomb (42);
}

  r := MaxReal;
  if IsNotANumber (r)   then Bomb (5);
  if IsInfinity (r)     then Bomb (6);
  if r <= 0             then Bomb (7);
  {$ifdef HAVE_INF}  { see emil4.cmp }
  r := r + r;
  if not (IsInfinity (r) or (r <= MaxReal))
  { `not IsInfinity (r)' alone probably can't work on non-IEEE hardware }
                        then Bomb (8);
  {$endif}

  r := EpsReal;
  if IsNotANumber (r)   then Bomb (9);
  if IsInfinity (r)     then Bomb (10);
  if r <= 0             then Bomb (11);
  r := r + 1;
  if r <= 1             then Bomb (12);
  r := EpsReal / 2 + 1;
  if r <> 1             then Bomb (13);

  if OK then WriteLn ('OK')
end.
