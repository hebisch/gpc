program t(output);

uses GPC;

type
fileptr=Integer;

var
foo :text;
at :fileptr;

begin
{ for Dos systems } AssignBinary (foo, GetTempFileName); rewrite (foo); erase (foo);
rewrite(foo);
writeln(foo, 'abc');
reset(foo);
while not eof(foo) do begin
        Write(foo^);
        get(foo)
        end;
writeln;
APPEND(foo);
writeln(foo, 'def');
reset(foo);
while not eof(foo) do begin
        Write(foo^);
        get(foo)
        end;
writeln;
reset(foo);
while not eoln(foo) do begin
        Write(foo^);
        get(foo)
        end;
writeln;
get(foo);
writeln('at TELL foo at ->', foo^, '<-');
at := filepos(foo);
get(foo);
writeln('after get foo at ->', foo^, '<-');
SEEK(foo, at);
writeln('after seek foo at ->', foo^, '<-');
reset(foo);
writeln('after reset foo at ->', foo^, '<-');
SEEK(foo,at);
writeln('after seek foo at ->', foo^, '<-');
end.
