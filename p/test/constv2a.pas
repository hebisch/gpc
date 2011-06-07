program constv2a(output);
type t1 = char;
     t2 = 0..15;
     t3 = (en1, en2);
     t4 = single;
     t5 = 'a'..'z';
     t6 = double;
     t7 = array[1..2] of t3;
     t8 = record f1 : t5 ; f2, f3 : integer end;
     t9 = packed record f1 : t3; f2 : t2 end;
     t10 = packed array[1..2] of t2;
     t11 = integer attribute (size = 16);
     t12 = packed 0..80;
     t13 = boolean;
     t14 = set of boolean;
     t15 = set of char;

var ok : boolean value true;

{$define tst(i)
var v##i : t##i;
procedure doit##i(const var s : t##i; p : pointer);
begin
  if @s <> p then begin
    writeln('failed: ', 't' #i);
    ok := false
  end
end;
}

{$define mk15(x) 
x(1) x(2) x(3) x(4) x(5) x(6) x(7) x(8) x(9) x(10)
x(11) x(12) x(13) x(14) x(15)
}

mk15(tst)

begin
{$define ct(i)
  doit##i(v##i, @v##i);
}
mk15(ct)  
  if ok then writeln('OK')
end
.
