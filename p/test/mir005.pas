program SetRanges5 (Output);
        { Written by: Mirsad Todorovac Nov 2001; copying by GPL.
        ------------------------------------------------------------
        Stresses setrange construction and adding; checks if there's
        more in SET than we've put in.
        lasts few seconds where I've tested it.}
const maxN = 255;

var
  SetA, SetB, SetC : set of 0 .. maxN value [];
  i, Len           : Cardinal;
  Failed           : Boolean = false;
  Start, EndR      : 0 .. maxN;

begin
  for i := 0 to maxN do
    if (i in SetA) or (i in SetB) or (i in SetC) then
      WriteLn ('Failed: SET not initialized empty!');

  for Len := 1 to maxN + 1 do
    begin
      for Start := 0 to maxN - Len + 1 do
        begin
          EndR := Start + Len - 1;
          {writeln('constr. range = ', start, ',', endr);}
          SetB := SetA + [Start .. EndR];
          for i := 0 to maxN do
            begin
              if ((i < Start) and (i in SetB)) or
                                  ((i > EndR) and (i in SetB)) then
                if not Failed then
                  begin
                    {It's sufficient for one example to fail to find a bug!}
                    Failed := True;
                    WriteLn('Failed: ', i,' outside range found IN SET! ',
                            '[',Start, '..', EndR,']');
                  end
            end
        end
    end;

  if not Failed then WriteLn ('OK')

end.
