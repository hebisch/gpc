program fjf594a;

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
  URes.a := p.a + 1;
  { It is allowed to assign a return value }
  AccessRestricted := URes;
end;

procedure Check (const p: UnrestrictedRecord);
begin
  if p.a = 356 then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  r1.a := 354;

  { Assigning a restricted return value to a restricted object }
  { @@ Verify if this should really be allowed????? }
  r2 := AccessRestricted (r1);

  { Passing a restricted object to unrestricted formal parameter is ok }
  r2 := AccessRestricted (r2);

  Check (r2)
end.
