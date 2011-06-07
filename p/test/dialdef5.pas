Program DialDef5;

{ FLAG --borland-pascal }

begin
  {$ifopt borland-pascal}
    writeln ( 'OK' );
  {$else }
    writeln ( 'failed' );
  {$endif }
end.
