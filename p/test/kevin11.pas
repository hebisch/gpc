program extend2(output);
{ Tests extend() on a file that ends on a newline }
var
   out : bindable text;
   ok : packed array[1..2] of char;
   b : BindingType;
begin
   b := binding(out);
   b.name := 'extend2.dat';
   bind(out, b);
   rewrite(out);
   writeln(out, 'O');
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
     writeln('Failed: ', ok);
end.
