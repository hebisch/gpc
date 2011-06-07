program bug1;
type longint=ptrint;
{.$X+}
type tfunc = function : pointer;
function baz : longint;
begin
  baz := 1024 * 2;
end;
var bar : tfunc;
function foo : longint;
begin
  foo := longint(@baz);  // force assignment.
end;
begin
 bar := tfunc (foo); { this is where Delphi and BP barf }
  if longint (bar()) = 2048 then WriteLn ('OK') else WriteLn ('failed');  // force call
end.
