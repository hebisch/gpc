program SetTest00 (Output);
        {Test of SET construction; known to fail on alpha-dec-osf4.0b?!? fixed.}

const maxN = 255;

var   SetA: set of 0..maxN value [];

begin
  {SetA := SetA + [33];}
  Include (SetA, 33);  {neither worked before fix!}

  if not (33 in SetA) then
    WriteLn ('Failed: 33 NOT IN SET after putting it IN!')
  else
    WriteLn ('OK')

end.
