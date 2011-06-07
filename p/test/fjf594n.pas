program fjf594n;

type
  UnrestrictedRecord = record
    a: Integer;
  end;
  RestrictedRecord = restricted UnrestrictedRecord;

var
  r2: RestrictedRecord;

begin
  with r2 do WriteLn ('failed')  { restricted variable in `with' }  { WRONG }
end.
