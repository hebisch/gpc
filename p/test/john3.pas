program objtest(input,output);
type obj=object
   a:integer;
   constructor initialize;
end;

procedure obj.initialize;  { WRONG }
begin
   a:=3;
end;

var a,b:obj;
begin
   writeln ('failed');
   halt;
   b.a:=0;
   a.initialize;
   b:=a;
   writeln(b.a);
end.
