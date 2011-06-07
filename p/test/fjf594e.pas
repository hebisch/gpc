program fjf594e;

type
  UnrestrictedRecord = record
    a: Integer;
  end;
  RestrictedRecord = restricted UnrestrictedRecord;

var
  r1: UnrestrictedRecord;
  r2: RestrictedRecord;

function AccessRestricted (p: UnrestrictedRecord): RestrictedRecord;
var URes: UnrestrictedRecord;
begin
  { The parameter is treated as unrestricted, even though the actual
    parameter may be a restricted object }
  URes.a := p.a;
  { It is allowed to assign a return value }
  AccessRestricted := URes;
end;

begin
  r1 := AccessRestricted (r2); { assigning a restricted return
                                 value to an unrestricted object }  { WRONG }
  WriteLn ('failed')
end.
