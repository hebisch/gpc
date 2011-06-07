Program DialDef2 ( Output );

{ FLAG -w --classic-pascal }

begin
  {$ifopt classic-pascal}
    writeln ( 'OK' );
  {$else }
    writeln ( 'failed' );
  {$endif }
end.
