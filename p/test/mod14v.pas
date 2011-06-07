module mod14v;
export mod14v=(dummy2);
const dummy2='dummy2';
procedure pf; forward;
type
myob1 = object
  procedure pb;
  procedure p; virtual;
  procedure q; virtual;
end;

operator foo_op (u, v: integer) w : integer;

operator foo_op (u: myob1; v: integer) w : integer;

var ob1a, ob1b, ob1c : myob1;

var va, vb , vc : integer;

type
myob2 = object (myob1)
  ptr : ^myob3;
  procedure p0;
  procedure r; virtual;
  procedure q; virtual;
  procedure p; virtual;
  procedure s;
end;
myob3 = object (myob2)
  procedure p0;
  procedure p; virtual;
  procedure q; virtual;
  procedure r; virtual;
  procedure s;
end;

operator foo_op (u: myob2; v: myob3) w : myob3;

procedure take(procedure p);
end;
{ implementation }
procedure take(procedure p);
begin
end;
operator foo_op (u: myob2; v : myob3) w : myob3;
begin
  w := u.ptr^
end;
operator foo_op (u: myob1; v: integer) w : integer;
begin
  w := v
end;
operator foo_op (u, v: integer) w : integer;
begin
  w := v
end;
procedure pf;
begin
end;
procedure myob1.pb;
begin
end;
procedure myob1.p;
begin
end;
procedure myob1.q;
begin
end;
procedure myob2.p0;
begin
end;
procedure myob2.p;
begin
end;
procedure myob2.q;
begin
end;
procedure myob2.s;
begin
end;
procedure myob2.r;
begin
end;

procedure myob3.p0;
begin
end;
procedure myob3.p;
begin
end;
procedure myob3.q;
begin
end;
procedure myob3.s;
begin
end;
procedure myob3.r;
begin
end;

end
.
