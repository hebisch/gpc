program fjf424a;

procedure Error (n : Integer);
begin
  WriteLn ('failed #', n);
  Halt
end;

begin
  if 5 div 2 <> 2 then Error (1);
  if 5 mod 2 <> 1 then Error (2);
  if -5 div 2 <> -2 then Error (3);
  if (-5) mod 2 <> 1 then Error (4);
  if (-7) mod 3 <> 2 then Error (5);
  if 5 div (-2) <> -2 then Error (6);
  if -5 div (-2) <> 2 then Error (7);
  if (-2 ** 2 > -3.9) or (-2 ** 2 < -4.1) then Error (8);
  if -2 pow 2 <> -4 then Error (9);
  if (-2) pow 2 <> 4 then Error (10);
  if -2 * (+3) <> -6 then Error (11);
  if +2 + (-3) <> -1 then Error (12);
  WriteLn ('OK')
end.
