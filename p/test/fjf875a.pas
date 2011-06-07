program fjf875a;

var
  a: packed record
       b: record
            c, d: Char
          end
     end;

begin
  a.b.c := 'O';
  a.b.d := 'K';
  with a.b do WriteLn (c, d)
end.
