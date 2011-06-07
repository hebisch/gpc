program fjf241;

{$W-}

type x=function:string;

function w:string;
begin
  w:='OK'
end;

function q(a:x):string;
begin
  q:=a
end;

begin
  writeln(q(w))
end.
