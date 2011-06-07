uses GPC;

var
  dialect:String(100)='Unspecified dialect';
  RangeCheck :Boolean=False;
  Base       :Boolean=True;
  Hex        :Boolean=True;
  whitespace :Boolean=False;
  RealISO7185:Boolean=False;
  valf       :Boolean=False;

const
  l1={$ifdef Standard}1{$else}17{$endif};
  fstsize=1000;

  LongestSize = SizeOf (LongestInt);
  TypeSizes: array [1 .. 5] of Integer =
    (SizeOf (ByteInt),
     SizeOf (ShortInt),
     SizeOf (Integer),
     SizeOf (MedInt),
     SizeOf (LongInt));

var
  infile:Text;
  instr,tmpstr:String(2000);
  inbuf:packed array[l1..l1+1000] of Char;
  run1,run2,tempint,tempint2:Integer;
  OK,White,Dummy:Boolean;
  bi:ByteInt;
  si:ShortInt;
  ni:Integer;
  mi:MedInt;
  li:LongInt;
  bc:Byte;
  sc:ShortCard;
  nc:Cardinal;
  mc:MedCard;
  lc:LongCard;
  sr:ShortReal;
  nr:Real;
  lr:LongReal;
  c,c2:Char;
  cr:'K'..'O';
  nst:String(100);
  sst:String[100];
  fst:packed array[{$ifdef Standard} 1 .. fstsize {$else} 2*l1+1..2*l1+fstsize {$endif}] of Char;
  cst:array[0..1000] of Char;

function strcmp (a,b:CString):Integer; external name 'strcmp';

function GetIOResult: Integer;
begin
  GetIOResult := IOResult
end;

function GetInOutRes: Integer;
begin
  GetInOutRes := InOutRes
end;

procedure SetInOutRes (i: Integer);
begin
  InOutRes := i
end;

function GetCString2String (s: CString): TString;
begin
  GetCString2String := CString2String (s)
end;

{$ifdef Classic}
function StrConcat (const s1, s2: String): TString;
begin
  StrConcat := s1 + s2
end;
{$else}
{$define StrConcat(A,B) A+B}
{$endif}

procedure Err (const s: String);
begin
  if run1=1 then Write(dialect,'.',run2:1,': ') else Write('Run #',run1:1,'.',run2:1,': ');
  WriteLn(s);
  OK:=False
end;

procedure ErrI (const typ: String; va, ve: LongestInt);
var tmpstr: TString;
begin
  WriteStr (tmpstr, 'value of ', typ, ' variable is `', va, ''', but should be `', ve, '''');
  Err (tmpstr)
end;

procedure ErrU (const typ: String; va, ve: LongestCard);
var tmpstr: TString;
begin
  WriteStr (tmpstr, 'value of ', typ, ' variable is `', va, ''', but should be `', ve, '''');
  Err (tmpstr)
end;

procedure ErrR (const typ: String; va, ve: LongestReal);
var tmpstr: TString;
begin
  WriteStr (tmpstr, 'value of ', typ, ' variable is `', va, ''', but should be `', ve, '''');
  Err (tmpstr)
end;

procedure ErrC (const typ: String; va, ve: Char);
var tmpstr: TString;
begin
  WriteStr (tmpstr, 'value of ', typ, ' variable is `', va, ''', but should be `', ve, '''');
  Err (tmpstr)
end;

procedure ErrS (const typ, va, ve: String);
var tmpstr: TString;
begin
  WriteStr (tmpstr, 'value of ', typ, ' variable is `', va, ''', but should be `', ve, '''');
  Err (tmpstr)
end;

procedure Halt1;
begin
  Halt (1)
end;

operator = (a,b:LongReal) = r:Boolean;
begin
  r := Abs (a - b) <= (Abs (a) + Abs (b)) * 1e-6
end;

operator = (a,b:Real) = r:Boolean;
begin
  r := Abs (a - b) <= (Abs (a) + Abs (b)) * 1e-6
end;

operator = (a:ShortReal;b:Real) = r:Boolean;
begin
  r := Abs (a - b) <= (Abs (a) + Abs (b)) * 1e-6
end;

function TO1 (const typ: String) = r: Boolean;
begin
  r := GetIOResult = 0;
  if not r then Err ('unexpected I/O error while reading ' + typ + ' variable')
end;

procedure TW (const typ: String);
begin
  if GetIOResult=0 then Err ('unexpected I/O success while reading ' + typ + ' variable')
end;

{$R-} {Only read-range-checking is tested}
