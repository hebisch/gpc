program fjf43;

procedure foo(o,k:integer); attribute (name = 'Foo');
begin
 writeln(chr(o),chr(k))
end;

procedure bar(...); attribute (name = 'Foo'); external;

begin
 bar(79,75)
end.
