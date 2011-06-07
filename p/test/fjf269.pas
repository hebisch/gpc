program fjf269;
{ FLAG -O0 }
var x:array['K'..'O']of string(2);ch,c,c2:char;b:boolean=true;
begin
for ch:=low(x)to high(x) do begin if b then c2:=ch;b:=false;c:=ch end;writeln(c,c2)
end.
