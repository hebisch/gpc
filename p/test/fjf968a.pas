program fjf968a;

var
  x: record
       a: Integer;
       b: 0 .. 5
     end = [a, b: 0];  { WRONG, according to EP 6.8.7.3 (cf. note 1) }

begin
end.
