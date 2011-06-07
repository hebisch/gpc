{$methods-always-virtual}
program view1d(output);
type c1 = class
            constructor make_it;
            procedure p1;
            procedure p2(i : integer);
            function f1: integer;
            function f2(i : integer) : integer;
            ai1, ai2, ai3 : integer;
          end;
     c2 = view of c1
            constructor make_it;
            ai1 : char; { WRONG }
          end;

constructor c1.make_it;
begin
end;

procedure c1.p1;
begin
end;
procedure c1.p2(i : integer);
begin
end;
function c1.f1: integer;
begin
  f1 := ai1;
end;
function c1.f2(i : integer):integer;
begin
  f2 := ai3;
  ai3 := i;
end;

begin
end
.

