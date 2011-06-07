{$W no-implicit-abstract}

program fjf636e;

type
  aBC = object
    f: Integer
  end;

  BBB = object (aBC)
    g: Integer
  end;

  C = abstract object
    f: Integer
  end;

  d = object (C)
    g: Integer
  end;

  Ee = object
    procedure Foo; abstract;
  end;

var
  v: aBC;
  w: BBB;
  x: d;

begin
  if TypeOf (v) <> TypeOf (aBC) then
    WriteLn ('failed 1 ', PtrInt (TypeOf (v)), ' ', PtrInt (TypeOf (aBC)))
  else if SizeOf (v) <> SizeOf (aBC) then
    WriteLn ('failed 2 ', SizeOf (v), ' ', SizeOf (aBC))
  else with TypeOf (v)^ do if Size <> SizeOf (aBC) then
    WriteLn ('failed 3 ', Size, ' ', SizeOf (aBC))
  else if NegatedSize <> -SizeOf (v) then
    WriteLn ('failed 4 ', NegatedSize, ' ', -SizeOf (v))
  else if Parent <> nil then
    WriteLn ('failed 5 ', PtrInt (Parent), ' ', 0)
  else if Name^ <> 'aBC' then
    WriteLn ('failed 6 ', Name^, ' aBC')
  else if TypeOf (w) <> TypeOf (BBB) then
    WriteLn ('failed 7 ', PtrInt (TypeOf (w)), ' ', PtrInt (TypeOf (BBB)))
  else if SizeOf (w) <> SizeOf (BBB) then
    WriteLn ('failed 8 ', SizeOf (w), ' ', SizeOf (BBB))
  else with TypeOf (BBB)^ do if Size <> SizeOf (w) then
    WriteLn ('failed 9 ', Size, ' ', SizeOf (w))
  else if NegatedSize <> -SizeOf (BBB) then
    WriteLn ('failed 10 ', NegatedSize, ' ', -SizeOf (BBB))
  else if Parent <> TypeOf (v) then
    WriteLn ('failed 11 ', PtrInt (Parent), ' ', PtrInt (TypeOf (v)))
  else if Name^ <> 'BBB' then
    WriteLn ('failed 12 ', Name^, ' BBB')
  else if Parent^.Name^ <> 'aBC' then
    WriteLn ('failed 13 ', Parent^.Name^, ' aBC')
  else if Parent^.Parent <> nil then
    WriteLn ('failed 14 ', PtrInt (Parent^.Parent), 0)
  else if TypeOf (x) <> TypeOf (d) then
    WriteLn ('failed 15 ', PtrInt (TypeOf (x)), ' ', PtrInt (TypeOf (d)))
  else if SizeOf (x) <> SizeOf (d) then
    WriteLn ('failed 16 ', SizeOf (x), ' ', SizeOf (d))
  else with TypeOf (d)^ do if Size <> SizeOf (x) then
    WriteLn ('failed 17 ', Size, ' ', SizeOf (x))
  else if NegatedSize <> -SizeOf (x) then
    WriteLn ('failed 18 ', NegatedSize, ' ', -SizeOf (x))
  else if Parent <> TypeOf (C) then
    WriteLn ('failed 19 ', PtrInt (Parent), ' ', PtrInt (TypeOf (C)))
  else if Name^ <> 'd' then
    WriteLn ('failed 20 ', Name^, ' d')
  else with TypeOf (C)^ do if Size <> 0 then
    WriteLn ('failed 21 ', Size, ' ', 0)
  else if NegatedSize <> -1 then
    WriteLn ('failed 22 ', NegatedSize, ' ', -1)
  else if Parent <> nil then
    WriteLn ('failed 23 ', PtrInt (Parent), ' ', 0)
  else if Name^ <> 'C' then
    WriteLn ('failed 24 ', Name^, ' C')
  else with TypeOf (Ee)^ do if Size <> 0 then
    WriteLn ('failed 25 ', Size, ' ', 0)
  else if NegatedSize <> -1 then
    WriteLn ('failed 26 ', NegatedSize, ' ', -1)
  else if Parent <> nil then
    WriteLn ('failed 27 ', PtrInt (Parent), ' ', 0)
  else if Name^ <> 'Ee' then
    WriteLn ('failed 28 ', Name^, ' Ee')
  else
    WriteLn ('OK')
end.
