program SetRanges2 (Output);
        { Tests (explicit) SET initialization to empty.
          Written by Mirsad Todorovac, Nov 2001. Copying by GPL. }

const maxN = 255;

var
  SetA, SetB, SetC : set of 0 .. maxN value [];
  i                : Cardinal;
  Failed           : Boolean = false;

begin

  for i := 0 to maxN do
    if (i in SetA) or (i in SetB) or (i in SetC) then
      begin
        if not Failed then
          begin
            WriteLn ('Failed: SET not initialized empty! ', i, ' found IN!');
              {It's sufficient to find one bad example to have found a bug!}
            Failed := True;
          end
      end;

  if not Failed then WriteLn ('OK')

end.
