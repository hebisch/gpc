program Carel2j;

type foo = real;

function testI: boolean;
   type
     p   = ^foo;
     foo = integer;
   var
     v   : p;
begin
    testI := SizeOf(v^) = SizeOf(integer);
end;

function testR: boolean;
   type
     p   = ^foo;
   var
     v   : p;
begin
    testR := SizeOf(v^) = SizeOf(real);
end;

begin
    if testI and testR then
           writeln('OK')
        else
           writeln('failed');
end.
