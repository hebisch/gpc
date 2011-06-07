program SetRanges4 (Output);
        { Written by: Mirsad Todorovac Nov 2001; copying by GPL.
        ------------------------------------------------------------
        Stresses setrange construction and adding; checks if there's
        all in SET what we've put in.
        lasts few seconds where I've tested it.}
const maxN = 255;

var
  SetA, SetB  : set of 0 .. maxN value [];
  i, Len      : Cardinal;
  Start, EndR : 0 .. maxN;
  Failed      : Boolean = false;

begin
  for i := 0 to maxN do
    if (i in SetA) or (i in SetB) then
      WriteLn ('Failed: SET not initialized empty!');

  for Len := 1 to maxN + 1 do
    begin
      for Start := 0 to maxN - Len + 1 do
        begin
          EndR := Start + Len - 1;
          {writeln('constr. range = ', start, ',', endr);}
          SetB := SetA + [Start .. EndR];
          for i:= 0 to maxN do
            begin
              if (i >= Start) and (i <= EndR) and not (i in SetB) then
                if not Failed then
                  begin
                    {It's sufficient for one example to fail to find a bug!}
                    Failed := True;
                    WriteLn ('Failed: ', i,' inside range found NOT IN SET! ',
                             '[', Start, '..', EndR,']');
                  end
            end
        end
    end;

    if not Failed then WriteLn ('OK')

end.
