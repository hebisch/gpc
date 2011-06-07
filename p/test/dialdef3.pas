Program DialDef3 ( Output );

{ FLAG -w --extended-pascal }

begin
  {$ifopt extended-pascal}
    writeln ( 'OK' );
  {$else }
    writeln ( 'failed' );
  {$endif }
end.
