program fjf594d;

type
  UnrestrictedRecord = record
    a: Integer;
  end;
  RestrictedRecord = restricted UnrestrictedRecord;

var
  r1: UnrestrictedRecord;
  r2: RestrictedRecord;

begin
  r2 := r1;       { assignment target is restricted }  { WRONG }
  WriteLn ('failed')
end.
