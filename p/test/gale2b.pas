program CharAndStrTypeTest(input, output);

const
 kStrB = 'B' + ''; {type canonical string}

begin
case 'x' of
 kStrB: writeln('Fail'); {WRONG}
end;
end.
