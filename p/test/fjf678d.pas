program fjf678d;

var
  a: record
       b, c: Char;
       d: Text
     end = ('K', 'O', ());  { WRONG }

begin
  WriteLn ('failed')
end.
