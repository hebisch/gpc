program extend3(output);
{ Tests extend() on a non-existant (empty) file }
var
   out : bindable text;
   ok : string(2);
   b : BindingType;
begin
   b := binding(out);
   b.name := 'extend3.dat';
   bind(out, b);
   extend(out);
   writeln(out, 'OK');
   close(out);
   reset(out);
   readln(out, ok);
   if ok = 'OK' then
     writeln(ok)
   else
     writeln('Failed.');
end.
