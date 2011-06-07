program SetRanges10 (Output);
        { Written by: Mirsad Todorovac Nov 2001; copying by GPL.
          ------------------------------------------------------------
          Stresses setrange construction and using with IN in FOR loop
          Checks if FOR i IN [..] loop mistakenly runs for i outside set range.
           (within 0..maxN range).
          lasts less than few seconds where I've tested it. t ~ maxN}

const maxN = 255;

var
  Flag               : array [0 .. maxN] of Boolean;
  i                  : Cardinal;
  Extra              : Boolean = False;
  Start, EndR, Ext_I : 0 .. maxN;

begin
  {To provoke a bug we use one method to set array, and different to test!
      (requires integer for loop to work)}

  Start := 32;
  EndR := 95;

  for i := 0 to maxN do
    Flag[i] := False;

  for i in [Start .. EndR] do
    Flag[i] := True;

  for i := 0 to maxN do
    if not Extra and ((i < Start) or (i > EndR)) and Flag[i] then
      begin
        Extra := True;
        Ext_I := i;
      end;

  if not Extra then
    WriteLn ('OK')
  else
    WriteLn ('Failed: ', Ext_I, ' set but not IN [', Start, '..', EndR, ']')

end.
