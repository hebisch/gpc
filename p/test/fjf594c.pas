program fjf594c;

type
  UnrestrictedRecord = record
    a: Integer;
  end;
  RestrictedRecord = restricted UnrestrictedRecord;

var
  r1: UnrestrictedRecord;
  r2: RestrictedRecord;

begin
  r1 := r2;       { assignment source is restricted }  { WRONG }
  WriteLn ('failed')
end.
