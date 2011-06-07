program fjf255k; // foo

{$define foo // foo } // foo
{$undef bar // foo } // foo

begin
{$ifdef foo // Delphi style comment in multi-
               line Pascal style ifdef }
  Write ('O');
{$else // foo }
  WriteLn ('failed');
{$endif // foo }
{$ifdef bar // again
               and again }
  WriteLn ('failed');
{$else // foo }
  WriteLn ('K');
{$endif // foo }
end.
