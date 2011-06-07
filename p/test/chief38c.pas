{ Got Bus Error in _p_InitFDR() on the Sparc. }

program chief38c;

var
  foo : packed record
    x : Byte;
    y : array [1 .. 2] of text
  end;

begin
  WriteLn ('OK')
end.
