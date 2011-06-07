program fjf173b;
var
  a:bindable file of char;
  b:bindable text;
  c,d:string(10);
  e:char;
begin
  rewrite(a,'test.dat');
  a^:='A';
  put(a);
  write(a,'B');
  close(a);
  extend(b,'test.dat');  { An implicit EOLn is appended, according to the standard. }
  b^:='C';
  put(b);
  write(b,'D');
  reset(b);
  readln(b,c);
  readln(b,d);
  {$i-}
  read(b,e);
  {$i+}
  if IOResult = 0 then
    begin
      writeln ('Failed: read past EOF was not recognized.');
      halt (1)
    end;
  close(b);
  if (c = 'AB') and (d = 'CD') then writeln('OK') else writeln('Failed: `', c, ''', `', d, '''')
{$extended-pascal}
end.
