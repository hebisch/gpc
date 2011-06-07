program fjf812b;

type
  t = record
      case Boolean of
        False: (a: x);  { WRONG }
        True: ()
      end;

begin
end.
