program delphi1c;
type 
  c1 = class
    constructor cs;
    destructor ds;
    procedure p;
    i : integer
  end;
  c2 = class (c1)
    constructor cs; override;
    cf : c1;
  end;

procedure failure;
begin
  writeln('failed');
  halt
end;

var j : integer;
    k : integer;
constructor c1.cs;
begin
  i := 0;
  if j = k then j := k + 1
  else failure
end;

destructor c1.ds;
begin
  if j = 5 then j := 6
  else failure
end;

procedure c1.p;
begin
  if i = j then j := j + 1
  else failure
end;

constructor c2.cs;
begin
  k := 1;
  c1.cs;
  if j = 2 then j := 3
  else failure;
  k := j;
  i := 4;
  cf := c1.cs;
end;

var v : c2;
begin
  j := 1;
  v := c2.cs;
  v.p;
  v.ds;
  if j = 6 then writeln('OK')
  else failure
end
.
