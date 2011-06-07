program fjf371;

uses GPC;

var Counter : Integer = 1;

procedure Test (Name, Value : CString);
begin
  if Value = nil then
    begin
      if CStringGetEnv (Name) <> nil then
        begin
          WriteLn ('failed #', Counter, ': ', CString2String (Name), ' should not be set');
          Halt
        end
    end
  else
    if CStringGetEnv (Name) = nil then
      begin
        WriteLn ('failed #', Counter, ': ', CString2String (Name), ' should be set');
        Halt
      end
    else if CStringComp (CStringGetEnv (Name), Value) <> 0 then
      begin
        WriteLn ('failed #', Counter, ': ', CString2String (Name), '=', GetEnv (CString2String (Name)), ', should be ', CString2String (Value));
        Halt
      end
end;

procedure TestAll (Foo, Bar, Baz, Qux : CString);
begin
  Test ('FOO', Foo);
  Test ('BAR', Bar);
  Test ('BAZ', Baz);
  Test ('QUX', Qux);
  Inc (Counter)
end;

begin
  TestAll ('qwe', 'asd', nil, nil);
  UnSetEnv ('FOO');
  TestAll (nil, 'asd', nil, nil);
  UnSetEnv ('FOO');
  TestAll (nil, 'asd', nil, nil);
  SetEnv ('BAR', 'yxc');
  TestAll (nil, 'yxc', nil, nil);
  SetEnv ('BAR', 'rtz');
  TestAll (nil, 'rtz', nil, nil);
  SetEnv ('BAR', '');
  TestAll (nil, '', nil, nil);
  UnSetEnv ('BAR');
  TestAll (nil, nil, nil, nil);
  SetEnv ('FOO', '');
  TestAll ('', nil, nil, nil);
  UnSetEnv ('BAZ');
  TestAll ('', nil, nil, nil);
  SetEnv ('BAZ', 'fgh');
  TestAll ('', nil, 'fgh', nil);
  UnSetEnv ('BAZ');
  TestAll ('', nil, nil, nil);
  SetEnv ('QUX', 'vbn');
  TestAll ('', nil, nil, 'vbn');
  SetEnv ('QUX', 'uio');
  TestAll ('', nil, nil, 'uio');
  SetEnv ('QUX', '');
  TestAll ('', nil, nil, '');
  UnSetEnv ('QUX');
  TestAll ('', nil, nil, nil);
  SetEnv ('QUX', '123');
  TestAll ('', nil, nil, '123');
  SetEnv ('BAR', '456');
  TestAll ('', '456', nil, '123');
  WriteLn ('OK')
end.
