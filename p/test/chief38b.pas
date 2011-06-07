{ Got Bus Error in _p_InitFDR() on the Sparc. }

program chief38b;

var
  foo : packed record
    x : Byte;
    y : record t: text end
  end;

begin
  WriteLn ('OK')
end.
