{ Fails intermittently on DJGPP, <3AC1EB77.6000300@@ujf-grenoble.fr>

  I could not reproduce this error, but I've fixed some bugs in
  handle_forward_pointers() and WRT to GPC's memory management that
  could have explained the intermittent problems. So I hope they're
  OK now and move the test out of todo/. If it still causes
  problems, let me know. -- Frank, 2002-01-22 }

program nicola2;
type
  Pa = ^a;  { WRONG }
begin
  WriteLn ('failed')
end.
