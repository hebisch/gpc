{ FLAG -Dwallclock=42 }

program procs(output,input,file3);

type
aray = array[1..20] of char;
alfa = packed array[1..10] of char;

var
a, d :alfa;
c :aray;
b :char;
i :integer;
file3 :text;
t : timestamp;

begin
writeln('Enter two lines');
while not eoln(input) do begin
        write(input^);
        get(input);
        end;
if input^ = ' ' then
        writeln;
readln(b);
if not eoln(input) then
        halt
else
        writeln(b);
for i:=0 to paramcount do begin
        a:=paramstr(i+1);
        writeln('i = ',i:1,'   arg = ',a);
        end;
flush(output);
rewrite(file3);
write(file3,'test');
page(file3);
reset(file3);
{linelimit(file3,20);
stlimit(5000);}
gettimestamp(t);
a:=date(t);   unpack(a,c,1);
a:=time(t);   unpack(a,c,11);
pack(c,11,d);
pack(c,1,a);
i:=1;
end.
