Program Pack1;

Var
  r: packed record
       a, b: Boolean;
       c: false..true;
       d: 0..3;
       e: -3..3;
       i: Integer;
     end { r };
  rb: Byte absolute r;

begin
  rb:= 0;
  with r do
    begin
      a:= false;
      b:= true;
      c:= false;
      d:= 2;
      e:= -1;
    end { with };
  if ( SizeOf ( r ) = 1 + SizeOf (Integer) ) and ( rb = {$ifdef __BITS_BIG_ENDIAN__} 2#01010111 {$else} 2#11110010 {$endif} ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed ', SizeOf (r), ' ', SizeOf (Integer), ' ', rb );
end.
