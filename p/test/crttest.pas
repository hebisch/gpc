{ COMPILE-CMD: crt.cmp }

{ Test of the CRT unit. Not much to test without initializing CRT,
  and initializing CRT would disturbe batch runs, except with XCurses
  (if the window manager doesn't require user intervention when
  opening a window) and with ncurses with I/O redirection ...
  So, to really test CRT, run CRTDemo manually and play with it ... ;-}

program CRTTest;

uses CRT;

begin
  Close (Output);
  Assign (Output, '');
  Rewrite (Output, '');
  if NormAttr = LightGray + $10 * Black then WriteLn ('OK') else WriteLn ('Failed')
end.
