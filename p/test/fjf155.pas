program fjf155;

type t=object
         constructor c;
       end;

constructor t.c;
begin
  writeln('OK')
end;

var v:^t;

begin
  new(v,c)
end.
