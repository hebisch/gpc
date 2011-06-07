program SetRanges3 (Output);
        { Testing SET explicit initialization.
          Written by Mirsad Todorovac, Nov 2001. Copying by GPL. }
const maxN = 255;

var
  SetA, SetB, SetC : set of 0 .. maxN value [0 .. maxN];
  i                : Cardinal;
  Failed           : Boolean = false;

begin

  for i := 0 to maxN do
    if not (i in SetA) or not (i in SetB) or not (i in SetC) then
      begin
        if not Failed then
          begin
            WriteLn ('Failed: SET not initialized full: ', i, ' NOT IN!');
            {It's sufficient to find one example to have found a bug!}
            Failed := True;
          end
      end;

  if not Failed then WriteLn ('OK')

end.
