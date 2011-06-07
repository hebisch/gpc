{ FLAG -S }

{ The compiler didn't give the required error. However, a missing
  label causes the assembler to report an error, but only on some
  versions -- gas 2.9.5 apparently does not. Maybe that's a gas
  bug, but anyway, the compiler should really recognize the error. }

program fjf558b;

label 9;

begin
  WriteLn ('failed');
  goto 9;
  { WRONG }
end.
