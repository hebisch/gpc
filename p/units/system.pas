{ BP and partly Delphi compatible System unit for GPC

  This unit is released as part of the GNU Pascal project. It
  implements some rather exotic BP and Delphi compatibility
  features. Even many BP and Delphi programs don't need them, but
  they're here for maximum compatibility. Most of BP's and Delphi's
  System units' features are built into the compiler or the RTS.

  Note: The things in this unit are really exotic. If you haven't
  used BP or Delphi before, you don't want to look at this unit. :-)

  This unit depends on the conditional defines `__BP_TYPE_SIZES__',
  `__BP_RANDOM__', `__BP_PARAMSTR_0__' and `__BP_NO_ALLOCMEM__'.

  If `__BP_TYPE_SIZES__' is defined (with the `-D__BP_TYPE_SIZES__'
  option), the integer data types will be redefined to the sizes
  they have in BP or Delphi. Note that this might cause problems,
  e.g. when passing var parameters of integer types between units
  that do and don't use System. However, of the BP compatibility
  units, only Dos and WinDos use such parameters, and they have been
  taken care of so they work.

  If `__BP_RANDOM__' is defined (`-D__BP_RANDOM__'), this unit will
  provide an exactly BP compatible pseudo random number generator.
  In particular, the range for integer randoms will be truncated to
  16 bits like in BP. The RandSeed variable is provided, and if it's
  set to the same value as BP's RandSeed, it produces exactly the
  same sequence of pseudo random numbers that BP's pseudo random
  number generator does (whoever might need this ... ;-). Even the
  Randomize function will behave exactly like in BP. However, this
  will not be noted unless one explicitly tests for it.

  If `__BP_PARAMSTR_0__' is defined (`-D__BP_PARAMSTR_0__'), this
  unit will change the value of `ParamStr (0)' to that of
  `ExecutablePath', overwriting the value actually passed by the
  caller, to imitate BP's/Dos's behaviour. However *note*: On most
  systems, `ExecutablePath' is *not* guaranteed to return the full
  path, so defining this symbol doesn't change anything. In general,
  you *cannot* expect to find the full executable path, so better
  don't even try it, or your program will (at best) run on some
  systems. For most cases where BP programs access their own
  executable, there are cleaner alternatives available.

  If `__BP_NO_ALLOCMEM__' is defined (`-D__BP_NO_ALLOCMEM__'), the
  two Delphi compatible functions `AllocMemCount' and `AllocMemSize'
  will not be provided. The advantage is that this unit will not
  have to `Mark' the heap which makes memory de-/allocations much
  faster if the program doesn't use `Mark' otherwise.

  Copyright (C) 1998-2006 Free Software Foundation, Inc.

  Authors: Peter Gerwinski <peter@gerwinski.de>
           Prof. Abimbola A. Olowofoyeku <African_Chief@bigfoot.com>
           Frank Heckenbach <frank@pascal.gnu.de>
           Dominik Freche <dominik.freche@gmx.net>

  This file is part of GNU Pascal.

  GNU Pascal is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published
  by the Free Software Foundation; either version 3, or (at your
  option) any later version.

  GNU Pascal is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with GNU Pascal; see the file COPYING. If not, write to the
  Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA.

  As a special exception, if you link this file with files compiled
  with a GNU compiler to produce an executable, this does not cause
  the resulting executable to be covered by the GNU General Public
  License. This exception does not however invalidate any other
  reasons why the executable file might be covered by the GNU
  General Public License. }

{$gnu-pascal,I-}
{$if __GPC_RELEASE__ < 20030303}
{$error This unit requires GPC release 20030303 or newer.}
{$endif}

module System;

export System = all (FileMode {$ifdef __BP_TYPE_SIZES__}, SystemInteger => Integer, SystemWord => Word {$endif});

import GPC (MaxLongInt => GPC_MaxLongInt);

var
  { Chain of procedures to be executed at the end of the program }
  ExitProc: ^procedure = nil;

  { Contains all the command line arguments passed to the program,
    concatenated, with spaces between them }
  CmdLine: CString;

  {$ifdef __BP_RANDOM__}
  { Random seed, initialized by Randomize, but can also be set
    explicitly }
  RandSeed: Integer attribute (Size = 32) = 0;
  {$endif}

type
  OrigInt = Integer;
  OrigWord = Word;

  { Delphi }
  SmallInt = Integer attribute (Size = 16);
  DWord    = Cardinal attribute (Size = 32);

  { Short BP compatible type sizes if wanted }
  {$ifdef __BP_TYPE_SIZES__}
  ByteBool      = Boolean attribute (Size = 8);
  WordBool      = Boolean attribute (Size = 16);
  LongBool      = Boolean attribute (Size = 32);
  ShortInt      = Integer attribute (Size = 8);
  SystemInteger = Integer attribute (Size = 16);
  LongInt       = Integer attribute (Size = 32);
  Comp          = Integer attribute (Size = 64);
  Byte          = Cardinal attribute (Size = 8);
  SystemWord    = Cardinal attribute (Size = 16);
  LongWord      = Cardinal attribute (Size = 32);  { Delphi }
  {$else}
  SystemInteger = Integer;
  SystemWord    = Word;
  {$endif}

  {$if False}  { @@ doesn't work well (dialec3.pas) -- when GPC gets short
                    strings, it will be unnecessary }
  {$ifopt borland-pascal}
  String = String [255];
  {$endif}
  {$endif}

const
  MaxInt     = High (SystemInteger);
  MaxLongInt = High (LongInt);

{ Return the lowest-order byte of x }
function  Lo (x: LongestInt): Byte;

{ Return the second-lowest-order byte of x }
function  Hi (x: LongestInt): Byte;

{ Swap the lowest-order and second-lowest-order bytes, mask out the
  higher-order ones }
function  Swap (x: LongestInt): SystemWord;

{ Store the current directory name (on the given drive number if
  drive <> 0) in s }
procedure GetDir (Drive: Byte; var s: String);

{ Dummy routine for compatibility. @@Use two overloaded versions
  rather than varargs when possible. }
procedure SetTextBuf (var f: Text; var Buf; ...);

{ Mostly useless BP compatible variables }
var
  SelectorInc: SystemWord = $1000;
  Seg0040: SystemWord = $40;
  SegA000: SystemWord = $a000;
  SegB000: SystemWord = $b000;
  SegB800: SystemWord = $b800;
  Test8086: Byte = 2;
  Test8087: Byte = 3;  { floating-point arithmetic is emulated
                         transparently by the OS if not present
                         in hardware }
  OvrCodeList: SystemWord = 0;
  OvrHeapSize: SystemWord = 0;
  OvrDebugPtr: Pointer = nil;
  OvrHeapOrg: SystemWord = 0;
  OvrHeapPtr: SystemWord = 0;
  OvrHeapEnd: SystemWord = 0;
  OvrLoadList: SystemWord = 0;
  OvrDosHandle: SystemWord = 0;
  OvrEmsHandle: SystemWord = $ffff;
  HeapOrg: Pointer absolute HeapLow;
  HeapPtr: Pointer absolute HeapHigh;
  HeapEnd: Pointer = Pointer (High (PtrCard));
  FreeList: Pointer = nil;
  FreeZero: Pointer = nil;
  StackLimit: SystemWord = 0;
  HeapList: SystemWord = 0;
  HeapLimit: SystemWord = 1024;
  HeapBlock: SystemWord = 8192;
  HeapAllocFlags: SystemWord = 2;
  CmdShow: SystemInteger = 0;
  SaveInt00: Pointer = nil;
  SaveInt02: Pointer = nil;
  SaveInt0C: Pointer = nil;
  SaveInt0D: Pointer = nil;
  SaveInt1B: Pointer = nil;
  SaveInt21: Pointer = nil;
  SaveInt23: Pointer = nil;
  SaveInt24: Pointer = nil;
  SaveInt34: Pointer = nil;
  SaveInt35: Pointer = nil;
  SaveInt36: Pointer = nil;
  SaveInt37: Pointer = nil;
  SaveInt38: Pointer = nil;
  SaveInt39: Pointer = nil;
  SaveInt3A: Pointer = nil;
  SaveInt3B: Pointer = nil;
  SaveInt3C: Pointer = nil;
  SaveInt3D: Pointer = nil;
  SaveInt3E: Pointer = nil;
  SaveInt3F: Pointer = nil;
  SaveInt75: Pointer = nil;
  RealModeRegs: array [0 .. 49] of Byte =
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0, 0, 0, 0);

{ Mostly useless BP compatible pointer functions }
function  Ofs (const x): PtrWord;
function  Seg (const x): PtrWord;
function  Ptr (Seg, Ofs: PtrWord): Pointer;
function  CSeg: PtrWord;
function  DSeg: PtrWord;
function  SSeg: PtrWord;
function  SPtr: PtrWord;

{ Routines to handle BP's 6 byte `Real' type which is formatted like
  this:

  47                                                   0
  -|------- -------- -------- -------- --------|--------
   |                                           |
   +----------+                   +------------+
  47 Sign Bit |  8..46 Mantissa   | 0..7 Biased Exponent

  This format does not support infinities, NaNs and denormalized
  numbers. The first digit after the binary point is not stored and
  assumed to be 1. (This is called the normalized representation of
  a binary floating point number.)

  In GPC, this type is represented by the type `BPReal' which is
  binary compatible to BP's type, and can therefore be used in
  connection with binary files used by BP programs.

  The functions `RealToBPReal' and `BPRealToReal' convert between
  this type and GPC's `Real' type. Apart from that, `BPReal' should
  be treated as opaque.

  The variables `BPRealIgnoreOverflow' and `BPRealIgnoreUnderflow'
  determine what to do in the case of overflows and underflows. The
  default values are BP compatible. }

var
  { Ignore overflows, and use the highest possible value instead. }
  BPRealIgnoreOverflow: Boolean = False;

  { Ignore underflows, and use 0 instead. This is BP's behaviour,
    but has the disadvantage of diminishing computation precision. }
  BPRealIgnoreUnderflow: Boolean = True;

type
  BPRealInteral = Cardinal attribute (Size = 8);
  BPReal = packed record
    Format: packed array [1 .. 6] of BPRealInteral
  end;

function RealToBPReal (r: Real) = BR: BPReal;
function BPRealToReal (const BR: BPReal) = RealValue: Real;

{ Heap management stuff }

const
  { Possible results for HeapError }
  HeapErrorRunError = 0;
  HeapErrorNil      = 1;
  HeapErrorRetry    = 2;

var
  { If assigned to a function, it will be called when memory
    allocations do not find enough free memory. Its result
    determines if a run time error should be raised (the default),
    or nil should be returned, or the allocation should be retried
    (causing the routine to be called again if the allocation still
    doesn't succeed).

    Notes:

    - Returning nil can cause some routines of the RTS and units
      (shipped with GPC or third-party) to crash when they don't
      expect nil, so better don't use this mechanism, but rather
      CGetMem where needed.

    - Letting the allocation be retried, of course, only makes sense
      if the routine freed some memory before -- otherwise it will
      cause an infinite loop! So, a meaningful HeapError routine
      should dispose of some temporary objects, if available, and
      return HeapErrorRetry, and return HeapErrorRunError when no
      (more) of them are available. }
  HeapError: ^function (Size: SystemWord): SystemInteger = nil;

{ Just returns HeapErrorNil. When this function is assigned to
  HeapError, GetMem and New will return a nil pointer instead of
  causing a runtime error when the allocation fails. See the comment
  for HeapError above. }
function  HeapErrorNilReturn (Size: SystemWord): SystemInteger;

{ Return the total free memory/biggest free memory block. Except
  under Win32 and DJGPP, these are expensive routines -- try to
  avoid them. Under Win32, MaxAvail returns the same as MemAvail, so
  don't rely on being able to allocate a block of memory as big as
  MaxAvail indicates. Generally it's preferable to not use these
  functions at all in order to do a safe allocation, but just try to
  allocate the memory needed using CGetMem, and check for a nil
  result. What makes these routines unrealiable is, e.g., that on
  multi-tasking systems, another process may allocate memory after
  you've called MemAvail/MaxAvail and before you get to do the next
  allocation. Also, please note that some systems over-commit
  virtual memory which may cause MemAvail to return a value larger
  than the actual (physical plus swap) memory available. Therefore,
  if you want to be "sure" (modulo the above restrictions) that the
  memory is actually available, use MaxAvail. }
function  MemAvail: Cardinal;
function  MaxAvail: Cardinal;

{ Delphi compatibility }

function  CompToDouble (x: Comp): Double;
function  DoubleToComp (x: Double): Comp;
{$ifndef __BP_NO_ALLOCMEM__}
function  AllocMemCount = Count: SystemInteger;
function  AllocMemSize = Size: SizeType;
{$endif}
procedure Assert (Condition: Boolean);
procedure DefaultAssertErrorProc (const Message, FileName: String; LineNumber: SystemInteger; ErrorAddr: Pointer);

var
  AssertErrorProc: ^procedure (const Message, FileName: String; LineNumber: SystemInteger; ErrorAddr: Pointer) = @DefaultAssertErrorProc;
  NoErrMsg: Boolean = False;

end;

function Lo (x: LongestInt): Byte;
begin
  Lo := LongestCard (x) and $ff
end;

function Hi (x: LongestInt): Byte;
begin
  Hi := (LongestCard (x) div $100) and $ff
end;

function Swap (x: LongestInt): SystemWord;
begin
  Swap := (LongestCard (x) and $ff) * $100 + (LongestCard (x) div $100) and $ff
end;

procedure GetDir (Drive: Byte; var s: String);
begin
  if Drive = 0 then
    s := FExpand (DirSelf)
  else
    s := FExpand (Succ ('a', Drive - 1) + ':')
end;

procedure SetTextBuf (var f: Text; var Buf; ...);
begin
  Discard (f);
  Discard (Buf)
end;

function Ofs (const x): PtrWord;
begin
  Ofs := PtrWord (@x)
end;

function Seg (const x): PtrWord;
begin
  Discard (x);
  Seg := 0
end;

function Ptr (Seg, Ofs: PtrWord): Pointer;
begin
  Ptr := Pointer ($10 * Seg + Ofs)
end;

type
  PointerType = ^Integer;  { any typed pointer will do }

function CSeg: PtrWord;
begin
  CSeg := Seg (PointerType (ReturnAddress (0))^)
end;

function DSeg: PtrWord;
begin
  DSeg := Seg (ExitProc)  { any global variable will do }
end;

function SSeg: PtrWord;
begin
  SSeg := Seg (PointerType (FrameAddress (0))^)
end;

function SPtr: PtrWord;
begin
  SPtr := Ofs (PointerType (FrameAddress (0))^)
end;

function RealToBPReal (r: Real) = BR: BPReal;
var
  Mantissa: Extended;
  Exponent: CInteger;
  Sign, x: OrigInt;
begin
  for x := 1 to 6 do BR.Format[x] := 0;
  if IsNotANumber (r) then
    RuntimeError (870)  { BP compatible 6 byte `Real' type does not support NaN values }
  else if IsInfinity (r) then
    RuntimeError (871)  { BP compatible 6 byte `Real' type does not support infinity }
  else
    begin
      SplitReal (r, Exponent, Mantissa);
      Inc (Exponent, $80);
      Sign := 0;
      if Mantissa < 0 then
        begin
          Mantissa := -Mantissa;
          Sign := 1
        end;
      if Exponent < 0 then  { number cannot be stored in BPReal due to an underflow }
        begin
          if not BPRealIgnoreUnderflow then
            RuntimeError (872)  { underflow while converting to BP compatible 6 byte `Real' type }
          { else Set BR to zero -- BR is pre-initialized with 0 already }
        end
      else if Exponent > 255 then
        if BPRealIgnoreOverflow then
          begin
            { Set BR to highest number representable in this format }
            for x := 1 to 6 do BR.Format[x] := $ff;
            and (BR.Format[6], not ((not Sign) shl 7))  { Set sign }
          end
        else
          RuntimeError (873)  { overflow while converting to BP compatible 6 byte `Real' type }
      else
        begin
          { Convert a non-infinite number }
          BR.Format[1] := Exponent;
          Mantissa := Mantissa * 2;
          if Mantissa < 1 then  { if r is normalized, first bit is set }
            begin
              if not BPRealIgnoreUnderflow then
                RuntimeError (874)  { cannot convert denormalized number to BP compatible 6 byte `Real' type }
              { else Set BR to zero -- BR is pre-initialized with 0 already }
            end
          else
            begin
              { Leave out the first bit }
              Mantissa := Mantissa - 1;
              for x := 1 to 39 do
                begin
                  Mantissa := Mantissa * 2;
                  if Mantissa >= 1 then
                    begin
                      or (BR.Format[6 - x div 8], 1 shl (7 - x mod 8));
                      Mantissa := Mantissa - 1
                    end
                end;
              { Set sign }
              and (BR.Format[6], not (1 shl 7));
              or (BR.Format[6], Sign shl 7)
            end
        end
    end
end;

function BPRealToReal (const BR: BPReal) = RealValue: Real;
var
  x: Cardinal;
  Mantissa, e: Real;
begin
  Mantissa := 0.5;
  e := 0.25;
  { Leave out the first bit }
  for x := 1 to 39 do
    begin
      Mantissa := Mantissa +
        ((BR.Format[6 - x div 8] and (1 shl (7 - x mod 8))) shr (7 - x mod 8)) * e;
      e := e / 2
    end;
  RealValue := Mantissa * Exp (Ln (2) * (BR.Format[1] - 128));
  if (BR.Format[6] and 128) <> 0 then
    RealValue := -RealValue
end;

{ Heap management stuff }

var
  OldGetMem   : GetMemType;
  OldFreeMem  : FreeMemType;
  MaxAvailSave: Pointer = nil;
  MaxAvailSize: SizeType = 0;

{$ifndef __BP_NO_ALLOCMEM__}
var
  FirstMark: Pointer;

function AllocMemCount = Count: SystemInteger;

  procedure CountBlock (aPointer: Pointer; aSize: SizeType; aCaller: Pointer);
  begin
    Discard (aPointer);
    Discard (aSize);
    Discard (aCaller);
    Inc (Count)
  end;

begin
  Count := 0;
  ForEachMarkedBlock (FirstMark, CountBlock)
end;

function AllocMemSize = Size: SizeType;

  procedure CountBlockSize (aPointer: Pointer; aSize: SizeType; aCaller: Pointer);
  begin
    Discard (aPointer);
    Discard (aCaller);
    Inc (Size, aSize)
  end;

begin
  Size := 0;
  ForEachMarkedBlock (FirstMark, CountBlockSize)
end;
{$endif}

function BPGetMem (Size: SizeType) = p: Pointer;
var Status: SystemInteger;
begin
  if (MaxAvailSave <> nil) and (Size <= MaxAvailSize) then
    begin
      if Size = MaxAvailSize then
        p := MaxAvailSave
      else
        p := CReAllocMem (MaxAvailSave, Size);
      MaxAvailSave := nil;
      MaxAvailSize := 0;
      if p <> nil then Exit
    end;
  if HeapError = nil then
    p := OldGetMem^ (Size)
  else
    begin
      repeat
        p := CGetMem (Size);
        if p <> nil then Exit;
        Status := HeapError^ (Size)
      until Status <> HeapErrorRetry;
      if Status = HeapErrorNil then p := UndocumentedReturnNil
    end
end;

procedure BPFreeMem (aPointer: Pointer);
begin
  if MaxAvailSave <> nil then
    begin
      CFreeMem (MaxAvailSave);
      MaxAvailSave := nil;
      MaxAvailSize := 0
    end;
  OldFreeMem^ (aPointer)
end;

function HeapErrorNilReturn (Size: SystemWord): SystemInteger;
begin
  Discard (Size);
  HeapErrorNilReturn := HeapErrorNil
end;

{$ifdef __GO32__}

type
  DPMIFreeInfo = record
    LargestAvailableFreeBlockInBytes,
    MaximumUnlockedPageAllocationInPages,
    MaximumLockedPageAllocationInPages,
    LinearAddressSpaceSizeInPages,
    TotalNumberOfUnlockedPages,
    TotalNumberOfFreePages,
    TotalNumberOfPhysicalPages,
    FreeLinearAddressSpaceInPages,
    SizeOfPagingFilePartitionInPages: Cardinal;
    Reserved: array [0..2] of Cardinal
  end;

function DPMIGetFreeMemInfo (var Info: DPMIFreeInfo): OrigInt; external name '__dpmi_get_free_memory_information';
function DPMIGetPageSize (var Size: Cardinal): OrigInt; external name '__dpmi_get_page_size';

function MemAvail: Cardinal;
var
  D: DPMIFreeInfo;
  W: Cardinal;
begin
  Discard (DPMIGetFreeMemInfo (D));
  Discard (DPMIGetPageSize (W));
  MemAvail := (D.TotalNumberOfUnlockedPages * W)
end;

function MaxAvail: Cardinal;
var
  D: DPMIFreeInfo;
  W: Cardinal;
begin
  Discard (DPMIGetFreeMemInfo (D));
  Discard (DPMIGetPageSize (W));
  MaxAvail := (D.TotalNumberOfFreePages * W)
end;

{$elif defined (_WIN32)}

type
  TMemoryStatus = record
    dwLength,
    dwMemoryLoad,
    dwTotalPhys,
    dwAvailPhys,
    dwTotalPageFile,
    dwAvailPageFile,
    dwTotalVirtual,
    dwAvailVirtual: OrigInt
  end;

procedure GlobalMemoryStatus (var Buffer: TMemoryStatus); attribute (stdcall); external name 'GlobalMemoryStatus';

function MemAvail: Cardinal;
var t: TMemoryStatus;
begin
  t.dwLength := SizeOf (TMemoryStatus);
  GlobalMemoryStatus (t);
  MemAvail := Min (t.dwAvailPhys + t.dwAvailPageFile, t.dwAvailVirtual)
end;

function MaxAvail: Cardinal;
begin
  MaxAvail := MemAvail
end;

{$else}

const
  { Parameters for MemAvail and MaxAvail }
  StartSize     = $100000;  { 1MB }
  MinSize       = $10;
  PrecisionBits = 5;
  MaxBlocks     = $10;

function FindLargestMemBlock (var p: Pointer): SizeType;
var
  Size, Step: SizeType;
  Bits: OrigInt;
begin
  Size := StartSize;
  p := CGetMem (Size);
  while (p <> nil) and (Size <= High (Size) div 2) do
    begin
      Size := 2 * Size;
      CFreeMem (p);
      p := CGetMem (Size)
    end;
  repeat
    Size := Size div 2;
    p := CGetMem (Size)
  until (p <> nil) or (Size <= MinSize);
  Bits := PrecisionBits;
  Step := Size;
  while (Bits > 0) and (Size >= 2 * MinSize) and (p <> nil) do
    begin
      Dec (Bits);
      CFreeMem (p);
      Inc (Size, Step);
      Step := Step div 2;
      repeat
        Dec (Size, Step);
        p := CGetMem (Size)
      until (p <> nil) or (Size <= MinSize)
    end;
  if p = nil then
    Size := 0
  else if Size = 0 then
    p := nil;
  FindLargestMemBlock := Size
end;

function MaxAvail: Cardinal;
begin
  if MaxAvailSave <> nil then CFreeMem (MaxAvailSave);
  MaxAvailSize := FindLargestMemBlock (MaxAvailSave);
  MaxAvail := MaxAvailSize
end;

function MemAvail: Cardinal;
type PMemList = ^PMemList;
var
  TotalSize, NewSize: SizeType;
  MemList, p: PMemList;
  LargeEnough: Boolean;
  Blocks: Integer;
begin
  TotalSize := MaxAvail;
  MemList := nil;
  Blocks := 0;
  repeat
    NewSize := FindLargestMemBlock (p);
    Inc (TotalSize, NewSize);
    LargeEnough := NewSize >= Max (SizeOf (p^), TotalSize shr PrecisionBits);
    if LargeEnough then
      begin
        p^ := MemList;
        MemList := p;
        p := nil;
        Inc (Blocks)
      end
  until not LargeEnough or (Blocks >= MaxBlocks);
  if p <> nil then CFreeMem (p);
  while MemList <> nil do
    begin
      p := MemList;
      MemList := MemList^;
      CFreeMem (p)
    end;
  MemAvail := TotalSize
end;
{$endif}

{ Delphi compatibility }

function CompToDouble (x: Comp): Double;
begin
  CompToDouble := x
end;

function DoubleToComp (x: Double): Comp;
begin
  DoubleToComp := Round (x)
end;

procedure Assert (Condition: Boolean);
begin
  { @@ parameters are dummies }
  if not Condition then AssertErrorProc^ ('', '', 0, ReturnAddress (0))
end;

procedure DefaultAssertErrorProc (const Message, FileName: String; LineNumber: SystemInteger; ErrorAddr: Pointer);
var s: TString;
begin
  WriteStr (s, Message, ' (', FileName, ':', LineNumber, ' ', PtrInt (ErrorAddr), ')');
  RuntimeErrorCString (EAssertString, s)
end;

{$ifdef __BP_RANDOM__}
{ BP compatible random number generator }
procedure NextRand;
begin
  RandSeed := {$local R-} $8088405 * RandSeed + 1 {$endlocal}
end;

function BP_RandInt (Range: LongestCard): LongestCard;
type Card64 = Cardinal attribute (Size = 64);
begin
  NextRand;
  BP_RandInt := ({$local R-} Card64 (RandSeed) {$endlocal} * (Range mod $10000)) div $100000000
end;

function BP_RandReal: LongestReal;
begin
  NextRand;
  BP_RandReal := RandSeed / $100000000 + 0.5
end;

procedure BP_SeedRandom (Seed: RandomSeedType);
begin
  RandSeed := Seed
end;

procedure BP_Randomize;
var Time: TimeStamp;
begin
  GetTimeStamp (Time);
  with Time do BP_SeedRandom (((Second * $100 + (MicroSecond div 10000)) * $100 + Hour) * $100 + Minute)
end;
{$endif}

to begin do
  begin
    OldGetMem     := GetMemPtr;
    OldFreeMem    := FreeMemPtr;
    GetMemPtr     := @BPGetMem;
    FreeMemPtr    := @BPFreeMem;
    {$ifdef __BP_RANDOM__}
    RandomizePtr  := @BP_Randomize;
    SeedRandomPtr := @BP_SeedRandom;
    RandRealPtr   := @BP_RandReal;
    RandIntPtr    := @BP_RandInt;
    {$endif}
    {$ifdef __BP_PARAMSTR_0__}
    if ParamCount >= 0 then
      CParameters^[0] := NewCString (ExecutablePath);
    {$endif}
    var CmdLineStr: TString; attribute (static);
    var i: OrigInt;
    CmdLineStr := ParamStr (1);
    for i := 2 to ParamCount do CmdLineStr := CmdLineStr + ' ' + ParamStr (i);
    CmdLine := CmdLineStr;
    {$ifndef __BP_NO_ALLOCMEM__}
    Mark (FirstMark)
    {$endif}
  end;

to end do
  begin
    while ExitProc <> nil do
      begin
        var Tmp: ^procedure;
        Tmp := ExitProc;
        ExitProc := nil;
        Tmp^
      end;
    if NoErrMsg then ErrorMessageString := ''
  end;

end.
