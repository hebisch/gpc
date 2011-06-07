program fjf255h; // foo

begin
{$if 1 // Delphi style comment in multi-
       // line Pascal style directive }
  Write ('O');
{$else // foo }
  WriteLn ('failed');
{$endif // foo }
{$if 0 // again
       // and again }
  WriteLn ('failed');
{$else // foo }
  WriteLn ('K');
{$endif // foo }
end.
