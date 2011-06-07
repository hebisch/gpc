program SetRanges7 (Output);
        { Written by: Mirsad Todorovac Nov 2001; copying by GPL.
          ------------------------------------------------------------
          Stresses setrange construction and IN operator.
           (all possile intervals within 0..maxN range).
          Unexpectedly passed on 64 bit Alpha!!! (when SET initializations
          and adding and subtracting tests failed. more specifically designed
          tests are required to isolate the bug.)
          lasts few seconds where I've tested it. Warning: t ~ maxN^3}
const maxN = 255;

var
  i, Len           : Cardinal;
  Start, EndR      : 0 .. maxN;
  Extra            : Boolean = False;
  Missing          : Boolean = False;
  ExtI, ExtS, ExtE, MisI, MisS, MisE : 0 .. maxN;

begin

  {Test whether the set was initialized properly is mir003.pas}

  for Len := 1 to maxN + 1 do
    for Start := 0 to maxN - Len + 1 do
      begin
        EndR := Start + Len - 1;
        {writeln('constr. range = ', start, ',', EndR);}
        for i := 0 to maxN do
          begin
            {It's sufficient for one example to fail to have found a bug!}
            {is i outside [start..EndR] found in??? it shouldn't be.}
            if ((i < Start) or (i > EndR)) and (i in [Start .. EndR]) then
              begin
                Extra := True;
                ExtI := i;
                ExtS := Start;
                ExtE := EndR;
              end;
            {is i, start<=i<=EndR found in [start..EndR] by IN operator???
             if not, we've found a bug!}
            if (i >= Start) and (i <= EndR) and not (i in [Start .. EndR]) then
              begin
                Missing := True;
                MisI := i;
                MisS := Start;
                MisE := EndR;
              end
          end
      end;

  if not Extra and not Missing then
    WriteLn ('OK')
  else
    begin
      Write ('Failed:');
      if Extra then
        Write (' extra: ', ExtI, ' IN [', 0, '..', maxN, ']-[', ExtS,
               '..', ExtE, ']');
      if Missing then
        Write (' miss: ', MisI, ' NOT IN [', 0, '..', maxN, ']-[',
               MisS, '..', MisE, ']');
      WriteLn
    end

end.
