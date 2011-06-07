Program DialDef6;

{ FLAG --delphi }

begin
  {$ifopt delphi}
    writeln ( 'OK' );
  {$else }
    writeln ( 'failed' );
  {$endif }
end.
