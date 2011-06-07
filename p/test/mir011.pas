program SetRanges11 (Output);
        { Written by: Mirsad Todorovac Nov 2001; copying by GPL.
          ------------------------------------------------------------
          Stresses setrange construction and using with IN in FOR loop
          Checks if FOR i IN [..] loop mistakenly skips some i inside [] range.
           (checks all subranges within 0..maxN range).
          lasts less than few seconds where I've tested it. t ~ maxN^3}

const maxN = 255;

var
  Flag                          : array [0 .. maxN] of Boolean;
  i                             : Cardinal;
  Missing                       : Boolean = False;
  Start, EndR, MisI, MisS, MisE : 0 .. maxN;

begin
  {To provoke a bug we use one method to set array, and different to test!
   (requires integer for loop to work)}

  for Start := 0 to maxN do
    for EndR := Start to maxN do
      begin
        for i := 0 to maxN do
          Flag[i] := False;

        for i in [Start .. EndR] do
          Flag[i] := True;

        for i := Start to EndR do
          if not Missing and not Flag[i] then
            begin
              Missing := True;
              MisI := i;
              MisS := Start;
              MisE := EndR;
            end
      end;

  if not Missing then
    WriteLn ('OK')
  else
    WriteLn ('Failed: ', MisI, ' NOT IN [', MisS, '..', MisE, ']')

end.
