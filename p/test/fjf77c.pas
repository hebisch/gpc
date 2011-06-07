{ Helper for fjf77cmp.pas: Get a lower estimate for "MaxLongReal". }

{$W no-float-equal}

program  { Line break, so it's not regarded as a test program on its own }
  fjf77c;

const
  Ten: LongReal = 10;

var
  i, i0, ir, j: Integer = 0;
  a, b: LongReal = 1;
  f: Text;

begin
  while a < MaxReal / 10 do
    begin
      Inc (i);
      a := a * 10
    end;
  ir := i;
  i0 := i;
  repeat
    Rewrite (f, 'test.dat');
    WriteLn (f, 'const i = ', i0, '; d: LongReal = 1e', i0, '; e: LongReal = 1e-', i0, ';');
    Close (f);
    i0 := i;
    j := Min (ir, Max (1, i div 10));
    Inc (i, j);
    b := a;
    a := a * Ten ** j  { This may abort (but the file has been written) ... }
  until a = b          { ... or this may terminate on infinity }
end.
