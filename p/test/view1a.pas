{$methods-always-virtual}
program view1a(output);
type ii = integer;
     c1 = class
            constructor make_it;
            procedure p1;
            procedure do_c1_p1;
            procedure p2(i : integer);
            function f2(i : integer) : integer;
            function do_c1_f2(i : integer) : integer;
            ai1, ai2, ai3 : ii;
          end;
     c2 = view of c1
            constructor make_it;
            procedure do_c1_p1;
            procedure p2(i : integer);
            function do_c1_f2(i : integer) : integer;
            ai1 : ii;
          end;
     c3 = class(c2)
            procedure p1;
            function f2(i : integer) : integer;
            ai2, ai3 : integer;
          end;

constructor c1.make_it;
begin
  ai3 := 77;
end;

procedure c1.p1;
begin
  ai1 := 667;
end;
procedure c1.do_c1_p1;
begin
  p1
end;
procedure c1.p2(i : integer);
begin
  ai2 := i
end;
function c1.f2(i : integer):integer;
begin
  f2 := ai3;
  ai3 := i;
end;
function c1.do_c1_f2(i : integer) : integer;
begin
  do_c1_f2 := f2(i)
end;

procedure c3.p1;
begin
  ai2 := 767;
end;
function c3.f2(i : integer):integer;
begin
  f2 := ai3;
  ai3 := i;
end;
var mc : c3;
    ok : boolean value true;
begin
  mc := c3.make_it;
  
  mc.ai1 := 0;
  mc.ai2 := 2;
  mc.do_c1_p1;

  ok := ok and (mc.ai1 = 667) and (mc.ai2 = 2);

  mc.ai1 := 0;
  mc.p1;
  ok := ok and (mc.ai1 = 0) and (mc.ai2 = 767);

  mc.ai3 := 135;
  ok := ok and (mc.ai3 = 135);
  ok := ok and (mc.f2(99) = 135); 
  ok := ok and (mc.ai3 = 99);
  if ok then
    writeln('OK')
end
.

