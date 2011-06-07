program Sven1;

var
  st : String(255) = 'OK';
  c  : char;

begin
  c := '5';

  if c in ['0'..'9'] then
    if Index('0123456789', c) = 6 then
      writeln ( st );
end.
