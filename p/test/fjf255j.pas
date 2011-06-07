program fjf255j; // foo

{$define foo // foo } // foo
{$undef bar // foo } // foo

begin
{$ifdef foo // Delphi style comment in Pascal style ifdef }
  Write ('O');
{$else // foo }
  WriteLn ('failed');
{$endif // foo }
{$ifdef bar // again }
  WriteLn ('failed');
{$else // foo }
  WriteLn ('K');
{$endif // foo }
end.
