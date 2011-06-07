program SetRange13 (Output);
        { Written by Mirsad Todorovac, Nov 2001. Copying by GPL.
          Stresses combinations of set construction of [j..k], j>k which
          are expected to be empty sets.
          Normally lasts few seconds, but t ~ maxN**3 !!
        }

const   maxN = 255;

var
  SetA    : set of 0 .. maxN;
  i, j, k : 0 .. maxN;
  Ok      : Boolean = True;

label   finish;

begin
  for j := 1 to maxN do
    for k := 0 to j-1 do
      begin
        SetA := [j .. k];  { should be empty set since j > k }
        for i := 0 to maxN do
          if i in SetA then
            if Ok then
              begin
                Ok := False;  { Nothing was supposed to be in empty set }
                Write ('Failed: ', i);
              end
            else
              Write (',', i);
        if not Ok then
          goto finish;
      end;

finish:
  if Ok then
    WriteLn ('OK')
  else
    WriteLn (' found in [', j, '..', k, '] (which should have been empty)!')

end.
