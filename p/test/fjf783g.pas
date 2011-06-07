program fjf783g;

type
  t = record
      case Integer of
        1, 6 .. 8: ();
        2, 4: ()
      end;

var
  v: ^t;

begin
  New (v, 9)  { WRONG }
end.
