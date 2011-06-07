Program DialDef7 ( Output );

{ FLAG --ucsd-pascal }

begin
  {$ifopt ucsd-pascal}
    writeln ( 'OK' );
  {$else }
    writeln ( 'failed' );
  {$endif }
end.
