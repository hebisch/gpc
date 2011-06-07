program fjf189;

type TStrings (Count, Length: Cardinal) = array [1 .. Count] of String (Length);

var s: TStrings (1, 42) = (1:'OK');

begin
  writeln(s[1])
end.
