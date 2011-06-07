Program DialDef1 ( Output );

{ FLAG -w --classic-pascal-level-0 }

begin
  {$ifopt classic-pascal-level-0}
    writeln ( 'OK' );
  {$else }
    writeln ( 'failed' );
  {$endif }
end.
