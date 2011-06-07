program ross1(input,output);
  type
        wordarray = array[0..15] of boolean;
        flags = (fcw0, fcw1, hc, d, pv, s, z, c, fcw8, fcw9, fcw10, fnvi, fvi,
                epa, sys, seg);
  var
        fcw : array [flags] of boolean;
procedure setbits(var store : wordarray);
  begin
          store[1] := true
  end;
  begin
          fcw := fcw;
          writeln ( 'OK' )
  end.
