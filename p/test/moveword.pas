{ Local i inserted, to avoid standard violation (which GPC now detects).
  Frank, 20030417 }

program moveword;

type t=array[1..32] of byte;

var
  a,b:t;
  i:integer;

procedure c (const n:char);
var i:integer;
begin
  for i:=2 to 32 do
    if a[i] <> i-1 then
      begin
        writeln('Failed: ',n,': ',a[i],'/',i-1);
        halt
      end
end;

begin
  for i:=1 to 32 do b[i]:=i;
  MoveLeft (b,a[2],31); c('l');
  MoveRight (b,a[2],31); c('r');
  writeln('OK')
end.
