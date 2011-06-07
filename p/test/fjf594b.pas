program fjf594b;

type
  UnrestrictedRecord = record
    a: Integer;
  end;
  RestrictedRecord = restricted UnrestrictedRecord;

var
  r2: RestrictedRecord;

begin
  r2.a := 100;    { field access (writing) }  { WRONG }
  WriteLn ('failed')
end.
