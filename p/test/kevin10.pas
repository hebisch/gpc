program extend1(output);
{ Tests extend() on a file not terminated with a newline }
var
   out : bindable text;
   ok : packed array[1..2] of Char;
   b : BindingType;

begin
   b := binding(out);
   b.name := 'extend1.dat';
   bind(out, b);
   rewrite(out);
   write(out, 'O');
   close(out);
   extend(out);
   writeln(out, 'K');
   close(out);
   reset(out);
   readln(out, ok[1]);
   readln(out, ok[2]);
   if ok = 'OK' then
     writeln(ok)
   else
     writeln('Failed.');
end.
