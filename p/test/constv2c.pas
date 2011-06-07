program constv2c(output);
{ This is a crash test, contains to many errors to be accepted by accident }
{ WRONG }
type 
     t1 = char;
     t2 = integer;
     t3 = 0..15;
     t4 = (en1, en2, en3, en4);
     t5 = en1..en2;

     t6 = 'a'..'z';
     t7 = pointer; 
     t8 = single;
     t9 = double;
     t10 = integer attribute (size = 16);
     t11 = packed 0..80;
     t12 = boolean;
     t13 = set of boolean;
     t14 = set of char;

var foo_base : integer;

const c1 = 'x';
      c2 = 7;
      c3 = 14;
      c4 = en2;
      c5 = en1;
      c6 = 'a';
      c7 = @foo_base;
      c8 = 1.0;
      c9 = 17.0;
      c10 = 717;
      c11 = 77;
      c12 = true;
      c13 = [true];
      c14 = ['a'..'c', 'f'];

var ok : boolean value true;

{$define tst(i, j, k)
procedure doit##j##i(k s : t##i);
begin
  if s <> v##i then begin
    writeln('failed: ', 't' #i, ' ', #j);
    ok := false
  end
end;
}
{$define tstn(i) 
var v##i : t##i;

tst(i, v, ) tst(i, c, const)}
{ tst(i, cv, const var) }

{$define mk14(x) 
x(11) x(12) x(13) x(14)}
{
x(1) x(2) x(3) x(4) x(5) x(6) x(7) x(8) x(9) x(10)
x(11) x(12) x(13) x(14)}
{ $define mk14(x) x(9)}


mk14(tstn)

begin
{$define ct(i)
  v##i := c##i;
  doitv##i(c##i);
  doitc##i(c##i);
  doitcv##i(c##i);
}
{$define ct1(i, j)
  doitv##i(c##j);
  doitc##i(c##j);
}
{
  doitcv##i(c##j);
}
{$define mk14j(x, j)
x(1, j) x(2, j) x(3, j) x(4, j) x(5, j) x(6, j) x(7, j) x(8, j) x(9, j) x(10, j)
x(11, j) x(12, j) x(13, j) x(14, j)}
{$define ct14(i)
mk14j(ct1, i)
}
mk14(ct14)  
  if ok then writeln('OK')
end
.
