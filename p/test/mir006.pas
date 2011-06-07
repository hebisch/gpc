program SetRanges6 (Output);
        { Written by: Mirsad Todorovac Nov 2001; copying by GPL.
        ------------------------------------------------------------
        Stresses setrange construction and subtraction; checks if there's
        all IN SET what we haven't subtracted; and whether anything we've
        subtracted remained mistakenly IN SET.
        lasts few seconds where I've tested it.}
const maxN = 255;

var
  SetA, SetB       : set of 0 .. maxN value [0 .. maxN];
  i, Len           : Cardinal;
  Start, EndR      : 0 .. maxN;
  Extra            : Boolean = false;
  Missing          : Boolean = false;
  ExtI, ExtS, ExtE, MisI, MisS, MisE : 0 .. maxN;

begin

  {Test whether the set was initialized to full properly is in mir003.pas}

  for Len := 1 to maxN + 1 do
    for Start := 0 to maxN - Len + 1 do
      begin
        EndR := Start + Len - 1;
        {writeln('constr. range = ', start, ',', endr);}
        SetB := SetA - [Start .. EndR];
        for i := 0 to maxN do
          begin
            {It's sufficient for one example to fail to have found a bug!}
            if (i >= Start) and (i <= EndR) and (i in SetB) then
              begin
                Extra := True;
                ExtI := i;
                ExtS := Start;
                ExtE := EndR;
              end;
            if ((i < Start) or (i > EndR)) and not (i in SetB) then
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
        Write (' extra: ', ExtI, ' IN [', 0, '..', maxN, ']-[', ExtS, '..',
               ExtE, ']');
      if Missing then
        Write (' miss: ', MisI, ' NOT IN [', 0, '..', maxN, ']-[', MisS,
               '..', MisE, ']');
      WriteLn
    end

end.
