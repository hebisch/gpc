program fjf781e;

var
  d: String (2); external name 'foo'; attribute (const);

begin
  d := 'XX'  { WRONG }
end.
