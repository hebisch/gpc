program fjf783a;

type
  t = record
      case Integer of
        1, 'x': ()  { WRONG }
      end;

begin
end.
