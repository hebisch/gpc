program stringtest;

type
  record_with_empty_string = record
                               empty_string : string(127) VALUE '';
                             end;
  some_records_with_empty_string(length : integer) = array[1..length] of
                record_with_empty_string;
  five_records_with_empty_string = some_records_with_empty_string(5);
var fr : five_records_with_empty_string;
begin
  writeln(fr[4].empty_string, 'OK')
end.

