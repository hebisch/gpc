{ This is about operator precedence of EP vs. BP. }

program fjf863a (Output);

begin

{$borland-pascal}
  if (-1 mod 2) <> -1 then WriteLn ('failed b1 ', -1 mod 2) else
  if ((-1) mod 2) <> -1 then WriteLn ('failed b2 ', (-1) mod 2) else
  if (not False and False) <> False then WriteLn ('failed b3 ', not False and False) else
  if (-1 and 2) <> 2 then WriteLn ('failed b4 ', -1 and 2) else
  if (--1) <> 1 then WriteLn ('failed b5 ', --1) else
  if (2*-1) <> -2 then WriteLn ('failed b6 ', 2*-1) else
  if (3+++--+-+-4) <> 7 then WriteLn ('failed b7 ', 3+++--+-+-4) else

{$W no-warnings,extended-pascal}
  if (-1 mod 2) <> -1 then WriteLn ('failed e1 ', -1 mod 2) else
  if ((-1) mod 2) <> 1 then WriteLn ('failed e2 ', (-1) mod 2) else
  if (not False and False) <> False then WriteLn ('failed e3 ', not False and False) else
  if (-1 {$gnu-pascal} and 2) <> 0 {$extended-pascal} then WriteLn ('failed e4 ', -1 {$gnu-pascal} and 2) else {$extended-pascal}

  WriteLn ('OK')
end.
