program movewor2;

const NumTests = 1;

type t=array[1..5000000] of byte;

procedure s (var a:t);
var i:integer;
begin
  for i:=1 to 5000000 do a[i]:=i mod $100
end;

procedure c (const a:t; const n:integer);
var i:integer;
begin
  for i:=3 to 4999997 do
    if a[i] <> (i-1) mod $100 then
      begin
        writeln('Failed: ',n,' ',i,': ',a[i],'/',(i-1) mod $100);
        halt
      end
end;

var
  foo:array [1..2] of t;
  a:t absolute foo[1];
  b:t absolute foo[2];
  i:integer;

begin
  s(b); for i:=1 to NumTests do MoveLeft      (b[2],a[3],sizeof (a)-5); c(a,1);
  s(b); for i:=1 to NumTests do Move          (b[2],a[3],sizeof (a)-5); c(a,2);
  s(a); for i:=1 to NumTests do MoveRight     (a[2],b[3],sizeof (b)-5); c(b,3);
  s(a); for i:=1 to NumTests do Move          (a[2],b[3],sizeof (b)-5); c(b,4);
  writeln('OK')
end.
