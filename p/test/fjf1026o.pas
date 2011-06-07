program fjf1026o;

var
  a: record
     case Integer of 1: (a: Integer)
     end value [case b: 1 of [a: 3]];  { WRONG }

begin
end.
