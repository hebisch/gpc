program fjf65;
type a(c:integer)=object  { WRONG }
        d:array[1..c] of integer;
        constructor q;
       end;

constructor a.q;
begin
end;

var b:a(3);
begin
  writeln ( 'failed' );
end.
