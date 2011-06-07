program fjf1026p;

var
  a: record
     case b: Integer of 1: (a: Integer)
     end value [case 1 of [a: 3]];  { WRONG }

begin
end.
