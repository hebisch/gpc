{ Failed with gcc-3.2.2 and `-march=i686'. }

program fjf880;

type
  CharSet = set of Char;

procedure foo (const s: CharSet; const a: String);
var i: Char;
begin
  for i in s do
    WriteLn (i, a)
end;

const c: Char = 'O';

begin
  foo ([c], 'K');
end.
