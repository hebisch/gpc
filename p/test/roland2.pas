program Roland2;

{$R-}  { Range-checking prevented this instance of the bug in some GPC
         versions as a side-effect, though the actual bug was still there. }

var
  i: Integer value 0;
  s: String (3);
  c: array [1 .. 2] of String (3) = ('K', 'abc');

function f: Integer;
begin
  Write ('O');
  Inc (i);
  f := i
end;

begin
  s := c[f];
  WriteLn (s)
end.
