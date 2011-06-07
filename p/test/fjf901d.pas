program fjf901d;

const
  s: CString = 'XYOKQ';

begin
  {$X+}
  WriteLn (s[Pred (3) .. Ord (^c)])
end.
