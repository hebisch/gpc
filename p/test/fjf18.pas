Program fjf18;

{In the following program, the capacity is not handled correctly.
x contains the full alphabet (though it shouldn't), and y contains
garbage (at least on Linux, not on DJGPP).}

{ Fixed. :}

var y,x:string(10);
    z: array [1..5] of char;
begin
  y:='';
  x:='1234567890';
  x:='abcdefghijklmnopqrstuvwxyz';
  z:='abcd';    { blank padded }
  z:='abcde';
  z:='abcdef';
  if ( x = 'abcdefghij' ) and ( y = '' ) and ( z = 'abcde' ) then
    writeln ( 'OK' )
  else
    begin
      writeln(x);
      writeln(y);
      writeln('[',z,']')
    end { else };
end.
