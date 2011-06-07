{ FLAG --field-widths=10:16 }

program testio(output);

const
str = 'foobar';
ch = 'c';
c13 = 13;
o13 = 8#13;
r13 = longreal(13.0);

type
alfa=string(100);
color = (red, green, blue, yellow, orange, violet, purple);

var
hue :color;
r :real;
i :integer;
strg :alfa;

begin
hue := hue;
r := 0;
for i := 1 to 12 do begin
        writeln(i:2,r:i,r:i:i,-r:i,-r:i:i,i*1.0:i:i,' ',i:i);
        r := 2*r+0.1;
        end;
i := 1;   r := 0;
writeln(i:2,r:1,r:1:1,-r:1,-r:1:1,i*1.0:1:1,' ',i:1);
i := i+1;   r := 2*r+0.1;
writeln(i:2,r:2,r:2:2,-r:2,-r:2:2,i*1.0:2:2,' ',i:2);
i := i+1;   r := 2*r+0.1;
writeln(i:2,r:3,r:3:3,-r:3,-r:3:3,i*1.0:3:3,' ',i:3);
i := i+1;   r := 2*r+0.1;
writeln(i:2,r:4,r:4:4,-r:4,-r:4:4,i*1.0:4:4,' ',i:4);
i := i+1;   r := 2*r+0.1;
writeln(i:2,r:5,r:5:5,-r:5,-r:5:5,i*1.0:5:5,' ',i:5);
i := i+1;   r := 2*r+0.1;
writeln(i:2,r:6,r:6:6,-r:6,-r:6:6,i*1.0:6:6,' ',i:6);
i := i+1;   r := 2*r+0.1;
writeln(i:2,r:7,r:7:7,-r:7,-r:7:7,i*1.0:7:7,' ',i:7);
i := i+1;   r := 2*r+0.1;
writeln(i:2,r:8,r:8:8,-r:8,-r:8:8,i*1.0:8:8,' ',i:8);
i := i+1;   r := 2*r+0.1;
writeln(i:2,r:9,r:9:9,-r:9,-r:9:9,i*1.0:9:9,' ',i:9);
i := i+1;   r := 2*r+0.1;
writeln(i:2,r:10,r:10:10,-r:10,-r:10:10,i*1.0:10:10,' ',i:10);
i := i+1;   r := 2*r+0.1;
writeln(i:2,r:11,r:11:11,-r:11,-r:11:11,i*1.0:11:11,' ',i:11);
i := i+1;   r := 2*r+0.1;
writeln(i:2,r:12,r:12:12,-r:12,-r:12:12,i*1.0:12:12,' ',i:12);
i := 13;
writeln(str,ch:2,ch,' ',13,c13,o13,r13,i);
strg:='1234567890';
for i:=5 to 15 do begin
        writeln('->',strg:i,'<-');
        end;
end.
