program fjf420b;

{$CSDefine FOO}

begin
  {$iFdeF foo}
  WriteLn ('failed 1');
  {$elif defined(foo)}
  WriteLn ('failed 2');
  {$ELif !defined(FOO)}
  WriteLn ('failed 3');
  {$enDIf}
  {$ifndef FOO}
  WriteLn ('failed 4');
  {$endif}
  WriteLn ('OK')
end.
