program init3f(output);
type ind = (i0, i1 , i2);
     ta = array[ind] of integer value [i0..i2: 1];
procedure check(var a : ta);
begin
  if (a[i0] <> 1) or (a[i1] <> 1) or (a[i2] <> 1) then
    writeln('failed')
  else
    writeln('OK')
end;
procedure foo;
  const i0 = 17;
        i1 = 11;
        i2 = 18;
  var va : ta;
begin
  check(va)
end;
begin
  foo
end
.
