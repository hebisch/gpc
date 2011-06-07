Program DialDef4 ( Output );

{ FLAG -w --object-pascal }

begin
  {$ifopt object-pascal}
    writeln ( 'OK' );
  {$else }
    writeln ( 'failed' );
  {$endif }
end.
