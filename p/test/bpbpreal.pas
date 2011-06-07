program BPBPReal;

{ Part of the BPRealTest. This program has to be compiled with BP
  and run after BPRealTest has completed successfully. It will read
  the data written by BPRealTest to bpreal.dat and check them. }

{$ifdef __GPC__}
begin
  WriteLn ('OK') { To not disturbe the test suite }
end
{$else}

{$N+,E+}

type
  RBR = packed record
    R : Double;
    BR : Real
  end;

var
  i : Integer;
  x : RBR;
  f : file of RBR;

begin
  Assign (f, 'bpreal.dat');
  {$I-}
  Reset (f);
  {$I+}
  if IOResult <> 0 then
    begin
      WriteLn ('Could not open `bpreal.dat''.');
      WriteLn ('Please run this test with BP *after* running bprealtest with GPC.');
      Halt (1)
    end;
  for i := 1 to FileSize (f) do
    begin
      Read (f, x);
      if Abs (x.R / x.BR - 1) > 1e-6 then
        begin
          WriteLn ('failed: ', x.R, ', ', x.BR);
          Halt (1)
        end
    end;
  WriteLn ('OK')
end
{$endif}.
