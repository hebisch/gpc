Program DialDef;

begin
  {$ifopt gnu-pascal}
    writeln ( 'OK' );
  {$else }
    writeln ( 'failed' );
  {$endif }
end.
