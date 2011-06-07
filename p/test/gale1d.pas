program FourCharCodeTest (input, output);

var
  s: String (10) = 'bool';

begin
  WriteLn (ord(substr(s,1,1)))  { WRONG }
end.
