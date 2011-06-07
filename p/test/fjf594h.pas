program fjf594h;

type
  UnrestrictedRecord = record
    a: Integer;
  end;
  RestrictedRecord = restricted UnrestrictedRecord;

var
  r2: RestrictedRecord;
  k: Integer;

begin
  k := r2.a;    { field access (reading) }  { WRONG }
  WriteLn ('failed')
end.
