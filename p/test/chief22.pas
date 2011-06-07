program bug2;

procedure x(const s:string);
begin
  writeln ( s );
end;

procedure y(s:string);
begin
  write ( s );
end;

var
ch:char;

begin
 ch :='O';
 y(ch);
 ch :='K';
 x(ch);
end.
