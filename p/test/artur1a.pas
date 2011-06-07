program tester;

function F1(a,b : string):boolean;
begin
    writeln('F1(',a,',',b,')',length(a),' ',length(b));
    F1:=true;
end;

procedure F2(a,b : string);
begin
//   writeln('F2(',a,',',b,')',length(a),' ',length(b)); //not necessary
	//when you add above, below works
    repeat until F1(a,b); //incorrect result
    repeat until F1('3','3'); //correct result //not necessary
end;

var c: string (255); //not necessary

begin
   c:='1'; //not necessary
   repeat until F1(c,c); //correct result //not necessary
   F2('2','2');
end.
