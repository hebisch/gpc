program SetRanges9 (Output);
        { Written by: Mirsad Todorovac Nov 2001; copying by GPL.
          ------------------------------------------------------------
          Stresses setrange construction and using with IN in FOR loop
          Checks if FOR i IN [..] loop mistakenly skips some i inside [] range.
           (within 0..maxN range).
          lasts less than few seconds where I've tested it. t ~ maxN}

const maxN = 255;

var
  Flag              : array [0 .. maxN] of Boolean;
  i                 : Cardinal;
  Missing           : Boolean = False;
  Start, EndR, MisI : 0 .. maxN;

begin
  {To provoke a bug we use one method to set array, and different to test!
   (requires integer for loop to work)}

  Start := 0;
  EndR := maxN;

  for i := 0 to maxN do
    Flag[i] := False;

  for i in [Start .. EndR] do
    Flag[i] := True;

  for i := Start to EndR do
    if not Missing and not Flag[i] then
      begin
        Missing := True;
        MisI := i;
      end;

  if not Missing then
    WriteLn ('OK')
  else
    WriteLn ('Failed: ', MisI, ' not set but IN [', Start, '..', EndR, ']')

end.
