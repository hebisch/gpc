program fjf783h;

type
  t = record
      case Integer of
        1: ();
        else ()
      end;

var
  v: ^t;

begin
  New (v, 0);
  New (v, 1);
  New (v, 2);
  New (v, 3);
  WriteLn ('OK')
end.
