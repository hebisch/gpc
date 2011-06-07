{$W no-parentheses}

{ FLAG --borland-pascal }

program fjf424c;

procedure Error (n : Integer);
begin
  WriteLn ('failed #', n);
  Halt
end;

begin
  if 5 div 2 <> 2 then Error (1);
  if 5 mod 2 <> 1 then Error (2);
  if -5 div 2 <> -2 then Error (3);
  if -5 mod 2 <> -1 then Error (4);
  if 5 div -2 <> -2 then Error (5);
  if 5 mod -2 <> 1 then Error (6);
  if -5 div -2 <> 2 then Error (7);
  if -5 mod -2 <> -1 then Error (8);
  if -2 * +3 <> -6 then Error (11);
  if +2 + -3 <> -1 then Error (12);
  if ----+-+-+-+-+++-+-+-3 <> +-+-+++++++--+-3 then Error (13); { Quite stupid, but BP... }
  { The following tests assume two's complement }
  if -2 and -3 <> -4 then Error (14);
  if -2 or -3 <> -1 then Error (15);
  if not -3 <> 2 then Error (16);
  if not --2 <> -3 then Error (17);
  WriteLn ('OK')
end.
