program funcs(output);

type
sint1=0..30000;
Sint2=-30000..30000;
lint1=0..100000;
Lint2=-100000..100000;
color=(red,yellow,blue);

var
i :sint1;
n :Sint2;
j :lint1;
m :Lint2;
k :real;
l :color;
ptr :^integer;

procedure assert(c:boolean;s:string);
begin
  if not c then
    begin
      writeln(s);
      halt
    end
end;

function expo(a:real):integer;
begin
  if a=0 then
    expo:=0
  else
    expo:=round(ln(abs(a))/ln(10)-0.49999)
end;

begin
k:=0.7853981635;
{ generate bound checks }
j:=98000;
j:=355;
i:=j;
i:=113;
m:=-25000;
m:=100;
n:=m;
n:=154;
assert(trunc(k) = 0, 'trunc(k)');
assert(round(k) = 1, 'round(k)');
assert(sqr(2.5) = 6.25, 'sqr(2.5)');
assert(sqr(j) = 126025, 'sqr(j)');
assert(sqr(i) = 12769, 'sqr(i)');
assert(succ(j) = 356, 'succ(j)');
assert(succ(i) = 114, 'succ(i)');
l:=yellow;
assert(succ(l) = blue, 'succ(l)');
assert(pred(l) = red, 'pred(l)');
assert(pred(j) = 354, 'pred(j)');
assert(pred(i) = 112, 'pred(i)');
assert(odd(i), 'odd(i)');
assert(odd(j), 'odd(j)');
assert(chr(j-355) = chr(0), 'chr(j-355)');
assert(sqrt(25) = 5.0, 'sqrt(25)');
assert(sqrt(m) = 10.0, 'sqrt(m)');
assert(sin(k)-cos(k) < 1e-7, 'sin(k)-cos(k)');
assert(ln(exp(k))-k < 1e-7, 'ln(exp(k)');
assert(arctan(1.0)-k < 1e-7, 'arctan(1.0)');
assert(expo(k) = -1, 'expo(k)');
assert(expo(-1e+10) = 10, 'expo(-1e+10)');
assert(expo(1e-10) = -10, 'expo(1e-10)');
new(ptr);
dispose(ptr);
assert(random <= 1.0, 'random <= 1.0');
assert(random >= 0.0, 'random >= 0.0');
writeln('OK')
end.
