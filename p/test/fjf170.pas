program fjf170;
Type
  RealType    = ShortReal;
  IntegerType = Integer attribute ( Size = BitSizeOf ( RealType ) );

Const
  N = 536870954;

Var
  r, r1, r3, r4:     RealType;
  i, i1, i2, i3, i4, i5: IntegerType;

{ On some machines, these casts cause floating point exceptions. }

begin
  i := N;
  IntegerType (r1) := i;
  r3 := RealType (i);
  r4 := i;
  r := N - 0.1;
  RealType (i1) := r;
  i3 := IntegerType (r);
  i4 := Round (r); { N }
  i5 := Trunc (r); { N - 1 }
  if (r1<>N) and (r3<>N) and (r4=N) and (r3 = r1) and (i1 = i3) and
     (i1<>N - 1) and (i1<>N) and (i3<>N - 1) and (i3<>N) and (Abs(i4-N)<=1000) and (Abs(i5-N)<=1000)
    then writeln('OK')
  else
    begin
      writeln ( 'failed: ' );
      if r1 = N then
        writeln ( 'r1 = ', r1 );
      if r3 = N then
        writeln ( 'r3 = ', r3 );
      if r4 <> N then
        writeln ( 'r4 = ', r4 );
      if r1 <> r3 then
        writeln ( 'r1 = ', r1, ' <> r3 = ', r3);
      if i1 <> i3 then
        writeln ( 'i1 = ', i1, ' <> i3 = ', i3);
      if i1 - N in [ -1, 0 ] then
        writeln ( 'i1 = ', i1 );
      if i3 -N in [ 0, -1 ] then
        writeln ( 'i3 = ', i3 );
      if Abs(i4-N)>1000 then
        writeln ( 'i4 = ', i4 );
      if Abs(i5-N)>1000 then
        writeln ( 'i5 = ', i5 )
    end
end.
