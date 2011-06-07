program fjf783c;

type
  t = record
      case Integer of
        1, 6 .. 8: ();
        2, 4: ()
      end;

var
  v: ^t;

begin
  New (v, 1);
  New (v, 2);
  New (v, 4);
  New (v, 6);
  New (v, 7);
  New (v, 8);
  WriteLn ('OK')
end.
