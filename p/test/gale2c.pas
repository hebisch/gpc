program CharAndStrTypeTest(input, output);

const
 kCharA = 'A'; {type char}
 kAlsoCharA = kCharA; {type char}

begin
case 'A' of
 kAlsoCharA: WriteLn ('OK') {OK};
end;
end.
