const
  b2l=1000;
  b2h=2000;
  rc=1234512345.6789067890678906789067890678906789067890;
  sc='Hello %i wor'#0'ld!';
  sc2='dlrow olleh';
  sc3='asdfgh';
  sc4='Hello world!';
  sc5='qwertzuiop';
  l1={$ifdef Standard}1{$else}6{$endif};
  w0={$ifdef Classic}1{$else}0{$endif};
  p0={$ifdef Standard}1{$else}0{$endif};
  emptystring='';

type
  xstring = string (1000);

var
  dialect:string(100)='Unspecified dialect';
  noblank:Boolean=False;
  capexp :Boolean=False;
  clipstr:Boolean=False;
  fint   :Integer=0;
  freal  :Integer=0;
  fbool  :Integer=0;
  flint  :Integer=0;
  flreal :Integer=0;

  i8 :ByteInt  =123;
  i16:ShortInt =12345;
  i32:Integer  =1234567890;
  im :MedInt   =1234567899;
  i64:Longint  =-7890123456789012345;
  c8 :ByteCard =234;
  c16:ShortCard=23455;
  c32:Cardinal =2345678901;
  cm :MedCard  =2345678902;
  c64:LongCard =12345678901234567890;
  sr:ShortReal=rc;
  r:Real=rc;
  lr:LongReal=rc;
  si:Single=rc;
  d:Double=rc;
  ex:Extended=rc;
  c:char='a';
  c0:char=#0;
  s:string(40)=sc;
  s2:string(12)=sc4;
  s3:packed array[l1..l1+9] of char=sc5;
  {$x+}cs:cstring=sc2;cs2:pchar=sc3;
  buf:string(1000)='';
  buf2:array[b2l..b2h] of char='';
  bc,bz:Integer;

  foo:text;
  run:Integer=0;
