program forewarning(input,output);
{
  Program to demonstrate issue with for-loop compilation warning under
Gnu Pascal. loopvar is a global variable used as a loop counter in both
subroutines and the main program.

  In the main program, this counter is used in a loop which does not call
any subroutines at all, and therefore there is no threat from the procedure
useloopvar to the loop variable. GPC still refuses to compile the program.

  -- Still this is wrong according to EP. GPC will now only warn about it
     in default mode. -- Frank
}
var loopvar: integer;

procedure useloopvar;
begin
   for loopvar := 1 to 1 do
      { writeln('useloopvar ',loopvar) }
      write (Succ ('N', loopvar))
end; { useloopvar }

begin
   useloopvar;
   {$local W-} for loopvar := 1 to 1 do {$endlocal}
      writeln(Succ ('J', loopvar));
end.
