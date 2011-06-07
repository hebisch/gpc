{ File handling routines

  Copyright (C) 1991-2006 Free Software Foundation, Inc.

  Authors: Jukka Virtanen <jtv@hut.fi>
           Frank Heckenbach <frank@pascal.gnu.de>
           Peter Gerwinski <peter@gerwinski.de>

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

unit Files; attribute (name = '_p__rts_Files');

interface

uses RTSC, Error, Heap, String1, String2, Time, FName;

type
  TextFile = Text;
  TOpenMode = (fo_None, fo_Reset, fo_Rewrite, fo_Append, fo_SeekRead, fo_SeekWrite, fo_SeekUpdate);
  PAnyFile = ^AnyFile;

  TOpenProc   = procedure (var PrivateData; Mode: TOpenMode);
  TSelectFunc = function  (var PrivateData; Writing: Boolean): Integer;  { called before SelectHandle, must return a file handle }
  TSelectProc = procedure (var PrivateData; var ReadSelect, WriteSelect, ExceptSelect: Boolean);  { called before and after SelectHandle }
  TReadFunc   = function  (var PrivateData; var   Buffer; Size: SizeType): SizeType;
  TWriteFunc  = function  (var PrivateData; const Buffer; Size: SizeType): SizeType;
  TFileProc   = procedure (var PrivateData);
  TFlushProc  = TFileProc;
  TCloseProc  = TFileProc;
  TDoneProc   = TFileProc;

{@internal}

const
  FileBufSize = 16384;

{ The Pascal file object }
type
  GPC_FDR = ^FDRType;
  FDRType = record
    DefaultFilBuf: LongestInt; { not array of Char, to ensure alignment! }
    FilSiz: SizeType;          { buffer size: if packed then in bits else bytes }
    FilBuf: PChars0;           { file buffer }
    FilNam: CString;           { internal name of the file }

    Status: packed record
      Text,         { Text file }
      Untyped,      { Untyped file }
      Extern,       { External file }
      FileName,     { Derive external file name from internal file name }
      IsBindable,   { File is bindable }
      Undef,        { File buffer is totally undefined }
      EOF,          { End of file is True }
      EOLn,         { End of line is True (text files only) }
      ExtB,         { External or bound file }
      Unread,       { Nothing read yet }
      LastEOLn,     { Last character read into buffer was EOLn (text files only) }
      LGet,         { Must do a get before next buffer reference (lazy I/O) }
      Excl,         { Open file in exclusive mode }
      Reading,      { File open for reading }
      Writing,      { File open for writing }
      Extending,    { File open for appending }
      ROnly,        { File opened but is read only }
      WOnly,        { File opened but is write only }
      Tty: Boolean  { Device is a Tty: flush output before Get }
    end;

    Binding: ^BindingType;     { binding of the file }
    BoundName: CString;        { name the binding refers to }
    BindingChanged: Boolean;

    { Internal buffering. Also used for ReadStr/WriteStr etc. }
    BufPtr: PChars0;  { *not* the Standard Pascal file buffer, that is FilBuf^ }
    BufSize, BufPos: SizeType;
    Flags: Integer;

    ExtNam: CString;          { external name of the file }
    NameToUnlink: CString;
    Handle: Integer;          { file handle }
    CloseFlag: Boolean;

    FormatStringCount, FormatStringN: Integer;
    FormatStringStrings: PPChars0;
    FormatStringLengths: PIntegers;

    PrivateData: PChars0;
    OpenProc:    TOpenProc;
    SelectFunc:  TSelectFunc;
    SelectProc:  TSelectProc;
    ReadFunc:    TReadFunc;
    WriteFunc:   TWriteFunc;
    FlushProc:   TFlushProc;
    CloseProc:   TCloseProc;
    DoneProc:    TDoneProc;

    InternalBuffer: array [0 .. FileBufSize - 1] of Char  { *not* the Standard Pascal file buffer, that is FilBuf^ }
  end;

  FDRRecord = record
    f: GPC_FDR
  end;

  { Association list for internal and external file names set with an RTS
    command line option, see init.pas (`IntName' is the file variable
    identifier, case-insensitive). }
  PFileAssociation = ^TFileAssociation;
  TFileAssociation = record
    Next: PFileAssociation;
    IntName, ExtName: CString
  end;

var
  GPC_Input:  GPC_FDR = nil; attribute (name = '_p_Input');
  GPC_Output: GPC_FDR = nil; attribute (name = '_p_Output');
  GPC_StdErr: GPC_FDR = nil; attribute (name = '_p_StdErr');

  { True if the EOLn hack is wanted.

    If False: EOLn will validate the file buffer if tst_UND

    If True, when EOLn is tested when all of the following are true
    - tst_UND
    - tst_UNREAD (nothing has been read after reset)
    - tst_TXT
    - tst_Tty
    - tst_LGET,
    then the EOLn test returns True.

    If the EOLn is *not tested*, it is False. This is to make programs with
    `if EOLn then ReadLn;' in the very beginning work, they skip the EOLn when
    they test it, if you don't test, you don't have to skip it. }
  EOLnResetHack: Boolean = False; attribute (name = '_p_EOLnResetHack');

  CurrentStdInFDR: GPC_FDR = nil; attribute (name = '_p_CurrentStdin');
  CurrentStdIn: Text absolute CurrentStdInFDR;

  FileAssociation: PFileAssociation = nil; attribute (name = '_p_FileAssociation');

procedure GPC_Bind (f: GPC_FDR; protected var b: BindingType); attribute (name = '_p_Bind');
function  GPC_Binding (protected f: GPC_FDR) = b: BindingType; attribute (name = '_p_Binding');
procedure GPC_Close (f: GPC_FDR); attribute (name = '_p_Close');
procedure GPC_Unbind (f: GPC_FDR); attribute (name = '_p_Unbind');
procedure GPC_Flush (f: GPC_FDR); attribute (name = '_p_Flush');
procedure FlushAllFiles; attribute (name = '_p_FlushAllFiles');
procedure Done_Files; attribute (name = '_p_Done_Files');
procedure InitFDR (var f: GPC_FDR; InternalName: CString; Size, Flags: Integer); attribute (name = '_p_InitFDR');
procedure DoneFDR (var f: GPC_FDR); attribute (name = '_p_DoneFDR');
procedure GPC_BlockWrite (f: GPC_FDR; IsAnyFile: Boolean; Buf: PChars0; Count: Cardinal; var Result: Cardinal); attribute (name = '_p_BlockWrite');
procedure InternalOpen (f: GPC_FDR; FileName: CString; Length: Integer; BufferSize: Integer; Mode: TOpenMode); attribute (name = '_p_InternalOpen');
procedure Initialize_Std_Files; attribute (iocritical, name = '_p_Initialize_Std_Files');
function  LazyGet (f: GPC_FDR): Pointer; attribute (ignorable, name = '_p_LazyGet');
function  LazyUnget (f: GPC_FDR): Pointer; attribute (name = '_p_LazyUnget');
function  LazyTryGet (f: GPC_FDR): Pointer; attribute (name = '_p_LazyTryGet');
procedure GPC_Get (f: GPC_FDR); attribute (name = '_p_Get');
function  GPC_EOF (f: GPC_FDR): Boolean; attribute (name = '_p_EOF');
function  GPC_EOLn (f: GPC_FDR): Boolean; attribute (name = '_p_EOLn');
procedure GPC_BlockRead (f: GPC_FDR; IsAnyFile: Boolean; Buf: PChars0; Count: Cardinal; var Result: Cardinal); attribute (name = '_p_BlockRead');
function  Read_Integer (f: GPC_FDR): LongestInt; attribute (name = '_p_Read_Integer');
function  Read_Cardinal (f: GPC_FDR): LongestCard; attribute (name = '_p_Read_Cardinal');
function  Read_LongReal (f: GPC_FDR): LongReal; attribute (name = '_p_Read_LongReal');
function  Read_ShortReal (f: GPC_FDR): ShortReal; attribute (name = '_p_Read_ShortReal');
function  Read_Real (f: GPC_FDR): Real; attribute (name = '_p_Read_Real');
function  Read_Char (f: GPC_FDR): Char; attribute (name = '_p_Read_Char');
function  Read_Boolean (f: GPC_FDR): Boolean; attribute (name = '_p_Read_Boolean');
function  Read_Enum (f: GPC_FDR; IDs: array of PString) = Res: Integer; attribute (name = '_p_Read_Enum');
function  Read_String (f: GPC_FDR; Str: PChars0; Capacity: Integer) = Length: Integer; attribute (name = '_p_Read_String');
procedure Read_FixedString (f: GPC_FDR; Str: PChars0; Capacity: Integer); attribute (name = '_p_Read_FixedString');
procedure Read_Line (f: GPC_FDR); attribute (name = '_p_Read_Line');
procedure Read_Init (f: GPC_FDR; Flags: Integer); attribute (name = '_p_Read_Init');
function  ReadStr_Init (s: PChars0; Length: Cardinal; aFlags: Integer) = f: GPC_FDR; attribute (name = '_p_ReadStr_Init');
procedure ReadWriteStr_Done (f: GPC_FDR); attribute (name = '_p_ReadWriteStr_Done');
function  Val_Done (f: GPC_FDR): Integer; attribute (name = '_p_Val_Done');

procedure Write_Flush (f: GPC_FDR); attribute (name = '_p_Write_Flush');
procedure Write_Integer  (f: GPC_FDR; Num: Integer;  Width: Integer); attribute (name = '_p_Write_Integer');
procedure Write_LongInt  (f: GPC_FDR; Num: LongInt;  Width: Integer); attribute (name = '_p_Write_LongInt');
procedure Write_Cardinal (f: GPC_FDR; Num: Cardinal; Width: Integer); attribute (name = '_p_Write_Cardinal');
procedure Write_LongCard (f: GPC_FDR; Num: LongCard; Width: Integer); attribute (name = '_p_Write_LongCard');
procedure Write_Real (f: GPC_FDR; x: LongReal; Width, Precision: Integer); attribute (name = '_p_Write_Real');
procedure Write_Boolean (f: GPC_FDR; b: Boolean; Width: Integer); attribute (name = '_p_Write_Boolean');
procedure Write_Enum (f: GPC_FDR; IDs: array of PString; v, Width: Integer); attribute (name = '_p_Write_Enum');
procedure Write_Char (f: GPC_FDR; ch: Char; Width: Integer); attribute (name = '_p_Write_Char');
procedure Write_String (f: GPC_FDR; s: PChars0; Length: Cardinal; Width: Integer); attribute (name = '_p_Write_String');
procedure Write_Line (f: GPC_FDR); attribute (name = '_p_Write_Line');
procedure Write_Init (f: GPC_FDR; Flags: Integer); attribute (name = '_p_Write_Init');
function  WriteStr_Init (s: PChars0; Capacity, Flags: Integer) = f: GPC_FDR; attribute (name = '_p_WriteStr_Init');
function  WriteStr_GetLength (f: GPC_FDR): Integer; attribute (name = '_p_WriteStr_GetLength');
function  FormatString_Init (Flags, Count: Integer) = f: GPC_FDR; attribute (name = '_p_FormatString_Init');
function  FormatString_Result (f: GPC_FDR; Format: Pointer): Pointer; attribute (name = '_p_FormatString_Result');
function  StringOf_Result (f: GPC_FDR): Pointer; attribute (name = '_p_StringOf_Result');
procedure GPC_Page (f: GPC_FDR); attribute (name = '_p_Page');
procedure GPC_Put (f: GPC_FDR); attribute (name = '_p_Put');
procedure GPC_SeekRead (f: GPC_FDR; NewPlace: FileSizeType); attribute (name = '_p_SeekRead');
procedure GPC_SeekWrite (f: GPC_FDR; NewPlace: FileSizeType); attribute (name = '_p_SeekWrite');
procedure GPC_SeekUpdate (f: GPC_FDR; NewPlace: FileSizeType); attribute (name = '_p_SeekUpdate');
procedure GPC_Seek (f: GPC_FDR; NewPlace: FileSizeType); attribute (name = '_p_Seek');
procedure GPC_Update (f: GPC_FDR); attribute (name = '_p_Update');
function  GPC_Position (f: GPC_FDR) = Pos: FileSizeType; attribute (name = '_p_Position');
function  GPC_FileSize (f: GPC_FDR): FileSizeType; attribute (name = '_p_FileSize');
function  GPC_LastPosition (f: GPC_FDR): FileSizeType; attribute (name = '_p_LastPosition');
function  GPC_Empty (f: GPC_FDR): Boolean; attribute (name = '_p_Empty');
procedure GPC_DefineSize (f: GPC_FDR; NewSize: FileSizeType); attribute (name = '_p_DefineSize');
procedure GPC_Truncate (f: GPC_FDR); attribute (name = '_p_Truncate');
function  GetErrorMessageFileName (protected var f: GPC_FDR): TString; attribute (name = '_p_GetErrorMessageFileName');
procedure GPC_Erase (f: GPC_FDR); attribute (name = '_p_Erase');
procedure SetFileTime (f: GPC_FDR; AccessTime: UnixTimeType; ModificationTime: UnixTimeType); attribute (name = '_p_SetFileTime');

{@endinternal}

{ Flags that can be `or'ed into FileMode. The default value of
  FileMode is FileMode_Reset_ReadWrite. The somewhat confusing
  numeric values are meant to be compatible to BP (as far as
  BP supports them). }
const
  { Allow writing to binary files opened with Reset }
  FileMode_Reset_ReadWrite      = 2;

  { Do not allow reading from files opened with Rewrite }
  FileMode_Rewrite_WriteOnly    = 4;

  { Do not allow reading from files opened with Extend }
  FileMode_Extend_WriteOnly     = 8;

  { Allow writing to text files opened with Reset }
  FileMode_Text_Reset_ReadWrite = $100;

var
  FileMode: Integer = FileMode_Reset_ReadWrite; attribute (name = '_p_FileMode');

{ Get the external name of a file }
function  FileName (protected var f: GPC_FDR): TString; attribute (name = '_p_FileName');

procedure IOErrorFile (n: Integer; protected var f: GPC_FDR; ErrNoFlag: Boolean); attribute (iocritical, name = '_p_IOErrorFile');

procedure GetBinding (protected var f: GPC_FDR; var b: BindingType); attribute (name = '_p_GetBinding');
procedure ClearBinding (var b: BindingType); attribute (name = '_p_ClearBinding');

{ TFDD interface @@ Subject to change! Use with caution! }
procedure AssignTFDD (var f: GPC_FDR;
                      aOpenProc:    TOpenProc;
                      aSelectFunc:  TSelectFunc;
                      aSelectProc:  TSelectProc;
                      aReadFunc:    TReadFunc;
                      aWriteFunc:   TWriteFunc;
                      aFlushProc:   TFlushProc;
                      aCloseProc:   TCloseProc;
                      aDoneProc:    TDoneProc;
                      aPrivateData: Pointer);     attribute (name = '_p_AssignTFDD');

procedure SetTFDD    (var f: GPC_FDR;
                      aOpenProc:    TOpenProc;
                      aSelectFunc:  TSelectFunc;
                      aSelectProc:  TSelectProc;
                      aReadFunc:    TReadFunc;
                      aWriteFunc:   TWriteFunc;
                      aFlushProc:   TFlushProc;
                      aCloseProc:   TCloseProc;
                      aDoneProc:    TDoneProc;
                      aPrivateData: Pointer);     attribute (name = '_p_SetTFDD');

{ Any parameter except f may be Null }
procedure GetTFDD    (var f: GPC_FDR;
                      var aOpenProc:    TOpenProc;
                      var aSelectFunc:  TSelectFunc;
                      var aSelectProc:  TSelectProc;
                      var aReadFunc:    TReadFunc;
                      var aWriteFunc:   TWriteFunc;
                      var aFlushProc:   TFlushProc;
                      var aCloseProc:   TCloseProc;
                      var aDoneProc:    TDoneProc;
                      var aPrivateData: Pointer); attribute (name = '_p_GetTFDD');

procedure FileMove (var f: GPC_FDR; NewName: CString; Overwrite: Boolean); attribute (iocritical, name = '_p_FileMove');

const
  NoChange = -1;  { can be passed to ChOwn for Owner and/or Group to not change that value }

procedure CloseFile (var f: GPC_FDR); attribute (name = '_p_CloseFile');
procedure ChMod (var f: GPC_FDR; Mode: Integer); attribute (iocritical, name = '_p_ChMod');
procedure ChOwn (var f: GPC_FDR; Owner, Group: Integer); attribute (iocritical, name = '_p_ChOwn');

{ Checks if data are available to be read from f. This is
  similar to `not EOF (f)', but does not block on "files" that
  can grow, like Ttys or pipes. }
function  CanRead (var f: GPC_FDR): Boolean; attribute (name = '_p_CanRead');

{ Checks if data can be written to f. }
function  CanWrite (var f: GPC_FDR): Boolean; attribute (name = '_p_CanWrite');

{ Get the file handle. }
function  FileHandle (protected var f: GPC_FDR): Integer; attribute (name = '_p_FileHandle');

{ Lock/unlock a file. }
function  FileLock (var f: GPC_FDR; WriteLock, Block: Boolean): Boolean; attribute (name = '_p_FileLock');
function  FileUnlock (var f: GPC_FDR): Boolean; attribute (name = '_p_FileUnlock');

{ Try to map (a part of) a file to memory. }
function  MemoryMap (Start: Pointer; Length: SizeType; Access: Integer; Shared: Boolean;
                     var f: GPC_FDR; Offset: FileSizeType): Pointer; attribute (name = '_p_MemoryMap');

{ Unmap a previous memory mapping. }
procedure MemoryUnMap (Start: Pointer; Length: SizeType); attribute (name = '_p_MemoryUnMap');

type
  Natural = 1 .. MaxInt;
  IOSelectEvents = (SelectReadOrEOF, SelectRead, SelectEOF, SelectWrite, SelectException, SelectAlways);

type
  IOSelectType = record
    f: PAnyFile;
    Wanted: set of IOSelectEvents;
    Occurred: set of Low (IOSelectEvents) .. Pred (SelectAlways)
  end;

{ Waits for one of several events to happen. Returns when one or
  more of the wanted events for one of the files occur. If they have
  already occurred before calling the function, it returns
  immediately. MicroSeconds can specify a timeout. If it is 0, the
  function will return immediately, whether or not an event has
  occurred. If it is negative, the function will wait forever until
  an event occurs. The Events parameter can be Null, in which case
  the function only waits for the timeout. If any of the file
  pointers (f) in Events are nil or the files pointed to are closed,
  they are simply ignored for convenience.

  It returns the index of one of the files for which any event has
  occurred. If events have occurred for several files, is it
  undefined which of these file's index is returned. If no event
  occurs until the timeout, 0 is returned. If an error occurs or the
  target system does not have a `select' system call and Events is
  not Null, a negative value is returned. In the Occurred field of
  the elements of Events, events that have occurred are set. The
  state of events not wanted is undefined.

  The possible events are:
  SelectReadOrEOF: the file is at EOF or data can be read now.
  SelectRead:      data can be read now.
  SelectEOF:       the file is at EOF.
  SelectWrite:     data can be written now.
  SelectException: an exception occurred on the file.
  SelectAlways:    if this is set, *all* requested events will be
                   checked for this file in any case. Otherwise,
                   checks may be skipped if already another event
                   for this or another file was found.

  Notes:
  Checking for EOF requires some reading ahead internally (just like
  the EOF function) which can be avoided by setting SelectReadOrEOF
  instead of SelectRead and SelectEOF. If this is followed by, e.g.,
  a BlockRead with 4 parameters, the last parameter will be 0 if and
  only the file is at EOF, and otherwise, data will be read directly
  from the file without reading ahead and buffering.

  SelectAlways should be set for files whose events are considered
  to be of higher priority than others. Otherwise, if one is
  interested in just any event, not setting SelectAlways may be a
  little faster. }
function  IOSelect (var Events: array [m .. n: Natural] of IOSelectType; MicroSeconds: MicroSecondTimeType): Integer; attribute (name = '_p_IOSelect');

{ A simpler interface to SelectIO for the most common use. Waits for
  SelectReadOrEOF on all files and returns an index. }
function  IOSelectRead (const Files: array [m .. n: Natural] of PAnyFile; MicroSeconds: MicroSecondTimeType): Integer; attribute (name = '_p_IOSelectRead');

{ Bind a filename to an external file }
procedure AssignFile   (var t: AnyFile; const FileName: String); attribute (name = '_p_AssignFile');
procedure AssignBinary (var t: Text; const FileName: String); attribute (name = '_p_AssignBinary');
procedure AssignHandle (var t: AnyFile; Handle: Integer; CloseFlag: Boolean); attribute (name = '_p_AssignHandle');

{ Under development }
procedure AnyStringTFDD_Reset (var f: GPC_FDR; var Buf: ConstAnyString); attribute (name = '_p_AnyStringTFDD_Reset');
{ @@ procedure AnyStringTFDD_Rewrite (var f: GPC_FDR; var Buf: VarAnyString); attribute (name = '_p_AnyStringTFDD_Rewrite'); }
procedure StringTFDD_Reset (var f: GPC_FDR; var Buf: ConstAnyString; var s: array [m .. n: Integer] of Char); attribute (name = '_p_StringTFDD_Reset');
{ @@ procedure StringTFDD_Rewrite (var f: GPC_FDR; var Buf: VarAnyString; var s: String); attribute (name = '_p_StringTFDD_Rewrite'); }

{@internal}
{ BP compatible seeking routines }
function  Internal_SeekEOF  (ff: GPC_FDR): Boolean; attribute (name = '_p_SeekEOF');
function  Internal_SeekEOLn (ff: GPC_FDR): Boolean; attribute (name = '_p_SeekEOLn');

procedure Internal_AssignFile (tt: GPC_FDR; const FileName: String); attribute (name = '_p_Assign');
procedure Internal_Assign (tt: GPC_FDR; FileName: CString; NameLength: Integer); attribute (name = '_p_InternalAssign');
procedure Internal_Rename (aFile: GPC_FDR; const NewName: String); attribute (name = '_p_Rename');
procedure Internal_ChDir (const Path: String); attribute (name = '_p_ChDir');
procedure Internal_MkDir (const Path: String); attribute (name = '_p_MkDir');
procedure Internal_RmDir (const Path: String); attribute (name = '_p_RmDir');

{ Various other versions of Reset, Rewrite and Extend are still overloaded magically }
procedure Internal_Reset   (f: GPC_FDR; const aFileName: String; FileNameGiven: Boolean; BufferSize: Integer); attribute (name = '_p_Reset');
procedure Internal_Rewrite (f: GPC_FDR; const aFileName: String; FileNameGiven: Boolean; BufferSize: Integer); attribute (name = '_p_Rewrite');
procedure Internal_Extend  (f: GPC_FDR; const aFileName: String; FileNameGiven: Boolean; BufferSize: Integer); attribute (name = '_p_Extend');
{@endinternal}

{ Returns True is a terminal device is open on the file f, False if
  f is not open or not connected to a terminal. }
function  IsTerminal (protected var f: GPC_FDR): Boolean; attribute (name = '_p_IsTerminal');

{ Returns the file name of the terminal device that is open on the
  file f. Returns the empty string if (and only if) f is not open or
  not connected to a terminal. }
function  GetTerminalName (protected var f: GPC_FDR): TString; attribute (name = '_p_GetTerminalName');

implementation

{$ifndef HAVE_NO_RTS_CONFIG_H}
{$include "rts-config.inc"}
{$endif}

#define RTS_CONSTANT(NAME, VALUE) const NAME = VALUE;
{$include "constants.def"}

const
  HaveFCntl = {$ifdef HAVE_FCNTL} True {$else} False {$endif};
  ValInternalError = 999;
  OpenErrorCode: array [TOpenMode] of Integer = (904, 442, 443, 445, 442, 443, 444);
  NewPage = "\f";
  NewLineChar: Char = NewLine;
  NewPageChar: Char = NewPage;
  EOT = #4;  { file name queries abort if first char is EOT }
  OrdSpaceNL = [Ord (' '), Ord ("\t"), Ord ("\n")];
  FalseString = 'False';
  TrueString  = 'True';

  { This is an implementation-dependent constant according to ISO 10206. }
  RealDefaultDigits = 15;

  { Sufficient width to hold a LongestInt in decimal representation }
  MaxLongestIntWidth = BitSizeOf (LongestInt) div 3 + 2;

  DefaultOpenProc  = TOpenProc  (-1);
  DefaultReadFunc  = TReadFunc  (-1);
  DefaultWriteFunc = TWriteFunc (-1);
  DefaultFlushProc = TFlushProc (-1);
  DefaultCloseProc = TCloseProc (-1);

type
  PFDRList = ^TFDRList;
  TFDRList = record
    Next: PFDRList;
    Item: GPC_FDR
  end;

var
  { Not nice, but saves us from allocating heap memory for each `ReadStr', `Val' etc. call. }
  LastReadWriteStrFDR: GPC_FDR = nil;

  { FDR list. Add an FDR to the list when opened, remove it when closed. The list
    can be used to flush buffered output on runtime error (dump everything before
    giving an error message) and when something is to be read from a terminal. }
  FDRList: PFDRList = nil;

{$define IOERROR(Error, ErrNoFlag, ErrorResult)
  begin
    IOError (Error, ErrNoFlag);
    Return ErrorResult
  end}

{$define IOERROR_CSTRING(Error, Str, ErrNoFlag, ErrorResult)
  begin
    IOErrorCString (Error, Str, ErrNoFlag);
    Return ErrorResult
  end}

{$define IOERROR_FILE(Error, f, ErrNoFlag, ErrorResult)
  begin
    IOErrorFile (Error, f, ErrNoFlag);
    Return ErrorResult
  end}

{ Must not be subroutines because of `ReturnAddress' }
{$define SaveReturnAddress SetReturnAddress (ReturnAddress (0))}
{$define DO_RETURN_ADDRESS(stmt)
  begin
    SaveReturnAddress;
    stmt;
    RestoreReturnAddress
  end}

procedure ClearStatus (f: GPC_FDR); attribute (inline);
begin
  FillChar (f^.Status, SizeOf (f^.Status), 0)
end;

procedure ResetStatus (f: GPC_FDR); attribute (inline);
begin
  f^.Status.EOF := False;
  f^.Status.EOLn := False;
  f^.Status.Unread := False;
  f^.Status.LastEOLn := False;
  f^.Status.LGet := False;
  f^.Status.Excl := False;
  f^.Status.Undef := True
end;

function IsOpen (f: GPC_FDR): Boolean; attribute (inline);
begin
  IsOpen := f^.Status.Reading or f^.Status.Writing
end;

procedure InitTFDD (f: GPC_FDR); attribute (inline);
begin
  with f^ do
    begin
      PrivateData := nil;
      OpenProc    := DefaultOpenProc;
      SelectFunc  := nil;
      SelectProc  := nil;
      ReadFunc    := DefaultReadFunc;
      WriteFunc   := DefaultWriteFunc;
      FlushProc   := DefaultFlushProc;
      CloseProc   := DefaultCloseProc;
      DoneProc    := nil
    end
end;

procedure ReInitFDR (f: GPC_FDR); attribute (inline);
begin
  ResetStatus (f);
  f^.Status.Reading := False;
  f^.Status.Writing := False;
  f^.Status.Extending := False;
  f^.Status.ROnly := False;
  f^.Status.WOnly := False;
  f^.Status.Tty := False;
  f^.BufPtr := PChars0 (@f^.InternalBuffer);
  f^.NameToUnlink := nil;
  f^.Handle := -1;
  f^.CloseFlag := True
end;

procedure ClearBuffer (f: GPC_FDR); attribute (inline);
begin
  f^.BufSize := 0;
  f^.BufPos := 0
end;

procedure FlushBuffer (f: GPC_FDR); attribute (inline);
begin
  { empty -- will be needed when we add write buffers }
  { if f^.Status.Writing then ... }
  Discard (f)
end;

{ Attempt to bind f to b.Name. Do not modify any fields in b. }
procedure GPC_Bind (f: GPC_FDR; protected var b: BindingType);
var
  Len, State, Slash: Integer;
  Permissions: Integer = 0;
  aMode: CInteger = 0;
  aUser, aGroup, aDevice, aINode, aLinks: CInteger = -1;
  ATime, MTime, CTime: UnixTimeType = -1;
  aSize: FileSizeType = -1;
  OK, OnlyDir, aSymLink, aDirectory, aSpecial: Boolean;
  p: Pointer;
  Name, DirName: TString;
begin
  if InOutRes <> 0 then Exit;
  if not f^.Status.IsBindable then IOERROR_FILE (402, f, False,);  { `Bind' applied to non-bindable %s }
  if f^.Binding <> nil then IOERROR_CSTRING (441, f^.BoundName, False,);  { File already bound to `%s' }
  Len := Length (b.Name);
  if (Len < 0) or (Len > High (b.Name)) then
    RuntimeWarningInteger ('external names of bound objects must not be longer than %d characters', High (b.Name));
  OnlyDir := False;
  { strip trailing dir separators }
  while (Len > 1) and (b.Name[Len] in DirSeparators) and (not OSDosFlag or (Len > 3) or (b.Name[2] <> ':')) do
    begin
      OnlyDir := True;
      Dec (Len)
    end;
  if Len = 0 then
    Name := ''
  else
    Name := Slash2OSDirSeparator (b.Name[1 .. Len]);
  if IsOpen (f) then
    { @@ Should we close it if it is opened instead of this? }
    RuntimeWarning ('`Bind'': file already opened; binding takes effect with the next open');
  { Unfortunately there is no knowledge if the file will be reset, rewritten or
    extended, so let the user have control via some fields in BindingType. }
  aDirectory := False;
  aSymLink := False;
  aSpecial := True;
  OK := True;
  if OSDosFlag and
     { Write-only Dos devices }
     (StrEqualCase (Name, 'prn')  or
      StrEqualCase (Name, 'lpt1') or
      StrEqualCase (Name, 'lpt2') or
      StrEqualCase (Name, 'lpt3') or
      StrEqualCase (Name, 'lpt4') or
      StrEqualCase (Name, 'nul')) then
    Permissions := MODE_WRITE
  else if (Name = '') or (Name = '-') or
          (OSDosFlag and
           { Read-Write Dos devices }
           (StrEqualCase (Name, 'aux') or
            StrEqualCase (Name, 'com1') or
            StrEqualCase (Name, 'com2') or
            StrEqualCase (Name, 'com3') or
            StrEqualCase (Name, 'com4') or
            StrEqualCase (Name, 'con'))) then
    Permissions := MODE_READ or MODE_WRITE
  else
    begin
      { Get the Stat results even if Access fails (e.g. due to suid) }
      aSpecial := False;
      State := Stat (Name, aSize, ATime, MTime, CTime, aUser, aGroup, aMode, aDevice, aINode, aLinks, aSymLink, aDirectory, aSpecial);
      Permissions := Access (Name, MODE_FILE or MODE_EXEC or MODE_WRITE or MODE_READ);
      if Permissions <> 0 then
        begin
          if State = 0 then
            begin
              if aDirectory or aSpecial then Permissions := Permissions and not MODE_FILE;
              if aDirectory then OK := False
            end
        end
      else
        begin
          { Check for permissions to write into the lowest directory (where the
            nonexisting file would be created), not /tmp/non1/non2/non3 }
          DirName := Name;
          Slash := Length (Name);
          while (Slash >= 1) and not (DirName[Slash] in DirSeparators) do Dec (Slash);
          if Slash < 1 then  { Nonexisting file in current directory }
            DirName := '.'
          else if Slash = Length (Name) then
            OK := False  { /directory/name/ending/with/slash/ -- path is not valid }
          else
            begin
              if Slash = 1 then Inc (Slash);  { root directory }
              Delete (DirName, Slash)  { get rid of the file component, leave the path }
            end;
          if OK then
            begin
              { Note: Don't set OK to False if access fails. If we did this,
                a set[ug]id program couldn't write to a directory writable by
                the effective [ug]id, but not by the real [ug]id. This way, it
                will be marked not writable, but the program can write to it
                if it really wants to. }
              State := Stat (DirName, Null, Null, Null, Null, Null, Null, Null, Null, Null, Null, Null, aDirectory, Null);
              if (State = -2) or ((State = 0) and aDirectory) then
                begin
                  Permissions := Access (DirName, MODE_WRITE);  { only write permissions are valid because the file did not exist }
                  aDirectory := False
                end
              else
                OK := False  { path is not valid }
            end
        end
    end;
  if OnlyDir and not aDirectory then
    begin
      Permissions := 0;
      OK := False;
    end;
  if not (OK or b.Force) then Exit;
  InitTFDD (f);
  f^.BindingChanged := True;
  p := SuspendMark;
  f^.BoundName := NewCString (Name);
  New (f^.Binding);
  ResumeMark (p);
  f^.Binding^ := b;
  with f^.Binding^ do
    begin
      Extensions_Valid := True;
      Readable         := (Permissions and MODE_READ)  <> 0;
      Writable         := (Permissions and MODE_WRITE) <> 0;
      Executable       := (Permissions and MODE_EXEC)  <> 0;
      Existing         := (Permissions and MODE_FILE)  <> 0;
      Directory        := aDirectory;
      Special          := aSpecial;
      SymLink          := aSymLink;
      Size             := aSize;
      AccessTime       := ATime;
      ModificationTime := MTime;
      ChangeTime       := CTime;
      User             := aUser;
      Group            := aGroup;
      Mode             := aMode;
      Device           := aDevice;
      INode            := aINode;
      Links            := aLinks;
      Bound            := True
    end
end;

procedure ClearBinding (var b: BindingType);
begin
  with b do
    begin
      Bound            := False;
      Force            := False;
      Extensions_Valid := False;
      Readable         := False;
      Writable         := False;
      Executable       := False;
      Existing         := False;
      Directory        := False;
      Special          := False;
      SymLink          := False;
      Size             := -1;
      AccessTime       := -1;
      ModificationTime := -1;
      ChangeTime       := -1;
      User             := -1;
      Group            := -1;
      Mode             := 0;
      Device           := -1;
      INode            := -1;
      Links            := -1;
      TextBinary       := False;
      Handle           := -1;
      CloseFlag        := True;
      Name             := ''
    end
end;

{ Return the binding of `f'. }
function GPC_Binding (protected f: GPC_FDR) = b: BindingType;
begin
  ClearBinding (b);
  if InOutRes <> 0 then Exit;
  if not f^.Status.IsBindable then IOERROR_FILE (403, f, False, b);  { `Binding' applied to non-bindable %s }
  if f^.Binding = nil then Exit;
  b := f^.Binding^;
  if CStringLength (f^.BoundName) > High (b.Name) then
    RuntimeWarningInteger ('bound name truncated to %d characters in `Binding''', High (b.Name));
  b.Name := CString2String (f^.BoundName)
end;

procedure GetBinding (protected var f: GPC_FDR; var b: BindingType);
begin
  b := GPC_Binding (f)
end;

procedure Unlink (f: GPC_FDR; FileName: CString; CanDelay: Boolean);
var n: Integer;
begin
  if CStringUnlink (FileName) <> 0 then
    { Dos does not like unlinking an opened file in some circumstances,
       so remember the file name and unlink it later from `Close'. }
    if OSDosFlag and CanDelay then
      begin
        n := CStringLength (FileName) + 1;
        f^.NameToUnlink := InternalNew (n);
        Move (FileName^, f^.NameToUnlink^, n)
      end
    else
      IOERROR_FILE (474, f, True,)  { error when trying to erase %s }
end;

procedure Close1 (f: GPC_FDR);
var
  Handle: Integer;
  p: PFDRList;
  pp: ^PFDRList;
begin
  { Remove the FDR from the list before doing anything else, in order
    to prevent endless error-handling recursion. }
  pp := @FDRList;
  while (pp^ <> nil) and (pp^^.Item <> f) do pp := @pp^^.Next;
  if pp^ <> nil then
    begin
      p := pp^;
      pp^ := p^.Next;
      InternalDispose (p)
    end;
  if not IsOpen (f) then Exit;
  { Don't check InOutRes here. We want to close the file even after an I/O error. }
  FlushBuffer (f);
  f^.Status.EOF := True;
  if f^.CloseProc = DefaultCloseProc then
    begin
      if f^.CloseFlag then
        begin
          Handle := f^.Handle;
          f^.Handle := -1;
          f^.CloseFlag := True;
          if (CloseHandle (Handle) <> 0) and (InOutRes = 0) then
            IOERROR_FILE (418, f, True,)  { error while closing %s }
        end
    end
  else if f^.CloseProc <> nil then
    DO_RETURN_ADDRESS (f^.CloseProc (f^.PrivateData^))
end;

procedure GPC_Close (f: GPC_FDR);
begin
  { Don't check InOutRes here. We want to close the file even after an I/O error. }
  Close1 (f);
  if f^.NameToUnlink <> nil then
    begin
      Unlink (f, f^.NameToUnlink, False);
      InternalDispose (f^.NameToUnlink);
      f^.NameToUnlink := nil
    end;
  if f^.ExtNam <> nil then
    begin
      if f^.Binding = nil then InternalDispose (f^.ExtNam);
      f^.ExtNam := nil
    end;
  ReInitFDR (f);
  f^.BindingChanged := True
end;

procedure CloseFile (var f: GPC_FDR);
begin
  GPC_Close (f)
end;

procedure GPC_Unbind (f: GPC_FDR);
begin
  if InOutRes <> 0 then Exit;
  if not f^.Status.IsBindable then IOERROR_FILE (404, f, False,);  { `Unbind' applied to non-bindable %s }
  if f^.Binding <> nil then
    begin
      DO_RETURN_ADDRESS (GPC_Close (f));
      InitTFDD (f);
      if InOutRes <> 0 then Exit;
      InternalDispose (f^.BoundName);
      InternalDispose (f^.Binding);
      f^.Binding := nil;
      f^.ExtNam := nil;
      f^.BindingChanged := True
    end
end;

procedure SetTFDD (var f: GPC_FDR;
                   aOpenProc: TOpenProc;
                   aSelectFunc: TSelectFunc;
                   aSelectProc: TSelectProc;
                   aReadFunc: TReadFunc;
                   aWriteFunc: TWriteFunc;
                   aFlushProc: TFlushProc;
                   aCloseProc: TCloseProc;
                   aDoneProc: TDoneProc;
                   aPrivateData: Pointer);
begin
  with f^ do
    begin
      OpenProc    := aOpenProc;
      SelectFunc  := aSelectFunc;
      SelectProc  := aSelectProc;
      ReadFunc    := aReadFunc;
      WriteFunc   := aWriteFunc;
      FlushProc   := aFlushProc;
      CloseProc   := aCloseProc;
      DoneProc    := aDoneProc;
      PrivateData := aPrivateData
    end
end;

procedure GetTFDD (var f: GPC_FDR;
                   var aOpenProc: TOpenProc;
                   var aSelectFunc: TSelectFunc;
                   var aSelectProc: TSelectProc;
                   var aReadFunc: TReadFunc;
                   var aWriteFunc: TWriteFunc;
                   var aFlushProc: TFlushProc;
                   var aCloseProc: TCloseProc;
                   var aDoneProc: TDoneProc;
                   var aPrivateData: Pointer);
begin
  with f^ do
    begin
      if @@aOpenProc   <> nil then aOpenProc    := OpenProc;
      if @@aSelectFunc <> nil then aSelectFunc  := SelectFunc;
      if @@aSelectProc <> nil then aSelectProc  := SelectProc;
      if @@aReadFunc   <> nil then aReadFunc    := ReadFunc;
      if @@aWriteFunc  <> nil then aWriteFunc   := WriteFunc;
      if @@aFlushProc  <> nil then aFlushProc   := FlushProc;
      if @@aCloseProc  <> nil then aCloseProc   := CloseProc;
      if @@aDoneProc   <> nil then aDoneProc    := DoneProc;
      if @aPrivateData <> nil then aPrivateData := PrivateData
    end
end;

procedure AssignTFDD (var f: GPC_FDR;
                      aOpenProc: TOpenProc;
                      aSelectFunc: TSelectFunc;
                      aSelectProc: TSelectProc;
                      aReadFunc: TReadFunc;
                      aWriteFunc: TWriteFunc;
                      aFlushProc: TFlushProc;
                      aCloseProc: TCloseProc;
                      aDoneProc: TDoneProc;
                      aPrivateData: Pointer);
begin
  SaveReturnAddress;
  Internal_Assign (f, '', 0);
  RestoreReturnAddress;
  SetTFDD (f, aOpenProc, aSelectFunc, aSelectProc, aReadFunc, aWriteFunc, aFlushProc, aCloseProc, aDoneProc, aPrivateData)
end;

procedure CheckFileType (f: GPC_FDR); attribute (inline);
begin
  f^.Status.Tty := GetTerminalNameHandle (f^.Handle, False, TtyDeviceName) <> nil
end;

procedure DoneFDR (var f: GPC_FDR);
begin
  SaveReturnAddress;
  GPC_Close (f);
  if f^.DoneProc <> nil then
    begin
      f^.DoneProc (f^.PrivateData^);
      f^.DoneProc := nil
    end;
  if f^.Status.IsBindable then GPC_Unbind (f);
  if f^.FilBuf <> PChars0 (@f^.DefaultFilBuf) then InternalDispose (f^.FilBuf);
  InternalDispose (f);
  f := nil;
  RestoreReturnAddress
end;

function ReadInternal (f: GPC_FDR; Buf: PChars0; Size: SizeType): SizeType; attribute (inline);
var Result: SignedSizeType;
begin
  if Size = 0 then Return 0;
  Result := ReadHandle (f^.Handle, Buf, Size);
  if Result < 0 then
    IOERROR_FILE (464, f, True, 0);  { error when reading from %s }
  { If we are reading from the options file and this is the end of
    CurrentStdIn, continue with the original Input instead of giving EOF. }
  if (Result = 0) and (CurrentStdInFDR <> nil) and (f <> CurrentStdInFDR) and (f^.Handle = CurrentStdInFDR^.Handle) then
    begin
      GPC_Close (CurrentStdInFDR);
      DoneFDR (CurrentStdInFDR);
      CurrentStdInFDR := nil;
      f^.Handle := 0;  { real stdin }
      f^.CloseFlag := False;
      CheckFileType (f);
      ReadInternal := ReadInternal (f, Buf, Size)  { read again }
    end
  else
    ReadInternal := Result
end;

{ Routine to flush files from Pascal }
procedure GPC_Flush (f: GPC_FDR);
begin
  if InOutRes <> 0 then Exit;
  FlushBuffer (f);
  if f^.Status.Writing and (f^.FlushProc <> nil) then
    if f^.FlushProc = DefaultFlushProc then
      FlushHandle (f^.Handle)
    else
      DO_RETURN_ADDRESS (f^.FlushProc (f^.PrivateData^))
end;

{ Flush buffers to synchronize output messages }
procedure FlushAllFiles;
var Scan: PFDRList;
begin
  Scan := FDRList;
  while Scan <> nil do
    begin
      FlushBuffer (Scan^.Item);
      Scan := Scan^.Next
    end
end;

procedure Done_Files;
var f: GPC_FDR;
begin
  FlushAllFiles;
  { Clean up all open files. Note: Any FDR cleaned up might have
    a TFDD whose close routine may close other files. However,
    FDRList will always be valid and is advanced in Close1. }
  while FDRList <> nil do
    begin
      { The argument to DoneFDR is a var parameter, and the list item is
        disposed from Close1, so make a copy here! }
      f := FDRList^.Item;
      DoneFDR (f)
    end
end;

function FileHandle (protected var f: GPC_FDR): Integer;
begin
  FileHandle := f^.Handle
end;

{ Name: internal name in program
  Size: file buffer size; in bits, if packed, else in bytes
  flags: see constants.def }
procedure InitFDR (var f: GPC_FDR; InternalName: CString; Size, Flags: Integer);
begin
  f := InternalNew (SizeOf (f^));
  if InternalName = nil then InternalError (905);  { File has no internal name }
  ClearStatus (f);
  if (Flags and fkind_TEXT)     <> 0 then f^.Status.Text := True;
  if (Flags and fkind_UNTYPED)  <> 0 then f^.Status.Untyped := True;
  if (Flags and fkind_EXTERN)   <> 0 then f^.Status.Extern := True;
  if (Flags and fkind_FILENAME) <> 0 then f^.Status.FileName := True;
  if (Flags and fkind_BINDABLE) <> 0 then f^.Status.IsBindable := True;
  ReInitFDR (f);
  InitTFDD (f);
  f^.Binding := nil;
  f^.BoundName := nil;
  f^.ExtNam := nil;
  f^.FilSiz := Size;
  if f^.FilSiz = 0 then f^.FilSiz := 1;
  { Allocate file buffer -- avoid heap allocation in the vast majority of cases }
  if f^.FilSiz <= SizeOf (f^.DefaultFilBuf) then
    f^.FilBuf := PChars0 (@f^.DefaultFilBuf)
  else
    f^.FilBuf := InternalNew (f^.FilSiz);
  f^.FilNam := InternalName;
  f^.BindingChanged := False
end;

function IsStdFile (f: GPC_FDR): Boolean; attribute (inline);
begin
  IsStdFile := (f = GPC_Input) or (f = GPC_Output) or (f = GPC_StdErr)
end;

{ Check if f has a binding, and if so, set its external name }
procedure CheckBinding (f: GPC_FDR); attribute (inline);
begin
  if f^.Binding <> nil then
    begin
      f^.Status.ExtB := True;
      if f^.BindingChanged then
        begin
          GPC_Close (f);
          f^.BindingChanged := False;
          if InOutRes <> 0 then Exit;
          f^.ExtNam := f^.BoundName
        end
    end
  else
    f^.Status.ExtB := f^.Status.Extern
end;

function CheckWritable (f: GPC_FDR): Boolean; attribute (inline, ignorable);
begin
  if f^.Status.Writing then
    CheckWritable := True
  else
    IOERROR_FILE (450, f, False, False)  { %s is not open for writing }
end;

function CheckReadable (f: GPC_FDR): Boolean; attribute (inline, ignorable);
begin
  if f^.Status.Reading then
    CheckReadable := True
  else
    IOERROR_FILE (452, f, False, False)  { %s is not open for reading }
end;

function CheckReadableNotEOF (f: GPC_FDR): Boolean; attribute (inline, ignorable);
begin
  if (InOutRes <> 0) or not CheckReadable (f) then
    CheckReadableNotEOF := False
  else if not f^.Status.EOF then
    CheckReadableNotEOF := True
  else if (f^.Flags and READ_STRING_MASK) <> 0 then
    IOERROR (550, False, False)  { attempt to read past end of string in `ReadStr' }
  else
    IOERROR_FILE (454, f, False, False)  { attempt to read past end of %s }
end;

procedure InternalBlockWrite (f: GPC_FDR; Buf: PChars0; Size: SizeType; Count: SizeType; var Result: Cardinal);
var
  m, n: SizeType;
  r: SignedSizeType;
begin
  m := 0;
  Count := Count * Size;
  if @Result <> nil then Result := 0;
  if (InOutRes <> 0) or not CheckWritable (f) then Exit;
  if (Count > 0) and (f^.WriteFunc <> nil) then
    repeat
      if f^.WriteFunc = DefaultWriteFunc then
        begin
          r := WriteHandle (f^.Handle, @Buf^[m], Count);
          if r < 0 then
            begin
              IOERROR_FILE (466, f, True,);  { error when writing to %s }
              n := 0
            end
          else
            n := r
        end
      else
        begin
          n := f^.WriteFunc (f^.PrivateData^, Buf^[m], Count);
          if (InOutRes <> 0) and (InOutResString = nil) then IOERROR_FILE (InOutRes, f, False,)
        end;
      Dec (Count, n);
      Inc (m, n)
    until (InOutRes <> 0) or (n <= 0) or (Count <= 0) or ((m mod Size = 0) and (@Result <> nil));
  if @Result <> nil then
    Result := m div Size
  else if (InOutRes = 0) and (Count > 0) then
    IOERROR_FILE (467 - Ord (m = 0), f, False,)  { error when writing to `%s'; cannot write all the data to `%s' }
end;

procedure GPC_BlockWrite (f: GPC_FDR; IsAnyFile: Boolean; Buf: PChars0; Count: Cardinal; var Result: Cardinal);
var n: Integer;
begin
  if IsAnyFile then n := 1 else n := f^.FilSiz;
  DO_RETURN_ADDRESS (InternalBlockWrite (f, Buf, n, Count, Result))
end;

procedure InternalWrite (Buf: PChars0; Size: SizeType; f: GPC_FDR); attribute (inline);
begin
  InternalBlockWrite (f, Buf, 1, Size, Null)
end;

procedure ReadBuffer (f: GPC_FDR);
var WasRead: Boolean;
begin
  WasRead := not f^.Status.Unread;
  f^.Status.Unread := False;
  f^.BufPos := 0;
  if f^.ReadFunc <> nil then
    begin
      if f^.Status.Tty then FlushAllFiles;
      if f^.ReadFunc = DefaultReadFunc then
        f^.BufSize := ReadInternal (f, f^.BufPtr, FileBufSize)
      else
        begin
          f^.BufSize := f^.ReadFunc (f^.PrivateData^, f^.BufPtr^, FileBufSize);
          if (InOutRes <> 0) and (InOutResString = nil) then IOERROR_FILE (InOutRes, f, False,)
        end;
      { According to the standard, when reading from a nonempty Text file,
        EOLn is always True just before EOF, even if there is no end of line
        at the end of the file. We do it only in standard Pascal modes, since
        it prevents detecting whether there actually is an EOLn in the file. }
      if f^.BufSize <> 0 then
        f^.Status.LastEOLn := f^.BufPtr^[f^.BufSize - 1] = NewLine
      else if ((RTSOptions and ro_SP_EOLn) <> 0) and f^.Status.Text
               and not f^.Status.LastEOLn and WasRead then
        begin
          f^.Status.LastEOLn := True;
          f^.BufPtr^[0] := NewLine;
          f^.BufSize := 1
        end
    end
  else
    f^.BufSize := 0
end;

function InternalGetC (f: GPC_FDR): Integer;
var ch: Char;
begin
  if (f^.Flags and READ_STRING_MASK) = 0 then
    begin
      if f^.Status.EOF then Return -1;
      if f^.BufPos >= f^.BufSize then ReadBuffer (f)
    end;
  if InOutRes = 0 then
    begin
      f^.Status.EOLn := False;
      if f^.BufPos < f^.BufSize then
        begin
          ch := f^.BufPtr^[f^.BufPos];
          Inc (f^.BufPos);
          if f^.Status.Text and (ch = NewLine) then
            begin
              f^.Status.EOLn := True;
              ch := ' '
            end;
          f^.FilBuf^[0] := ch;
          Return Ord (ch)
        end;
      f^.Status.EOF := True;
      f^.Status.EOLn := True
    end;
  InternalGetC := -1
end;

function DirectGetC (f: GPC_FDR): Integer; attribute (inline);
begin
  if not f^.Status.LGet then
    begin
      f^.Status.LGet := True;
      Return Ord (f^.FilBuf^[0])
    end;
  { If buffer is undefined, read in new contents }
  Return InternalGetC (f)
end;

function DirectGetCCheckEOF (f: GPC_FDR): Integer; attribute (inline);
var ch: Integer;
begin
  ch := DirectGetC (f);
  if CheckReadableNotEOF (f) then
    DirectGetCCheckEOF := ch
  else
    DirectGetCCheckEOF := -1
end;

procedure UnGetCh (f: GPC_FDR; ch: Integer); attribute (inline);
begin
  if ch < 0 then Exit;
  Assert (f^.Status.LGet);
  f^.Status.LGet := False;
  f^.FilBuf^[0] := Chr (ch)
end;

{ Move the file pointer to the requested Pascal record of the file. n specifies
  how much to move, negative is backward, positive is forward. }
function SeekInternal (f: GPC_FDR; n: FileSizeType; Whence: Integer): Boolean; attribute (ignorable);
var ByteNum: FileSizeType;
begin
  if (Whence = SeekRelative) and not f^.Status.LGet then Dec (n);
  ByteNum := n * f^.FilSiz;
  if (Whence = SeekRelative) and (f^.BufPos < f^.BufSize) then Dec (ByteNum, f^.BufSize - f^.BufPos);
  ClearBuffer (f);
  f^.Status.LGet := True;
  if (Whence = SeekRelative) and (ByteNum = 0) then
    SeekInternal := True  { omit nops }
  else
    begin
      FlushBuffer (f);
      SeekInternal := SeekHandle (f^.Handle, ByteNum, Whence) >= 0
    end
end;

{ Open a file in Mode, depending on its binding etc.

  fo_Reset:
  pre-assertion:
    The components f0.L and f0.R are not undefined
  post-assertion:
    (f.L = S ()) and (f.R = (f0.L~f0.R~X))
    and (f.M = Inspection)
    and (if f.R = S () then (f^ is undefined) else (f^ = f^.R.first))

  fo_Rewrite:
  pre-assertion:
    True
  post-assertion:
    (f.L = f.R = S ()) and (f.M = Generation) and (f^ is undefined)

  fo_Append:
  pre-assertion:
    f0.L and f0.R are not undefined
  post-assertion:
    (f.M = Generation) and (f.L = f0.L~f0.R~X)
    and (f.R = S ())
    and (f^ is undefined)

  where, if F is of type Text, and f0.L~f0.R is not empty and
  if (f0.L~f0.R).last is not an end-of-line, then X shall be a
  sequence having an end-of-line component as its only component;
  otherwise X = S (). }
procedure Open (f: GPC_FDR; Mode: TOpenMode);

  function NameIt (f: GPC_FDR; Mode: TOpenMode): CString;
  var
    Tty, fin, fout, n, l: Integer;
    ap: PFileAssociation;
    Tmp: CString;
    Buf, Buf2: TString;
  begin
    if InOutRes <> 0 then Return nil;
    if not f^.Status.ExtB then
      begin
        f^.Status.Excl := True;
        Return GetTempFileName_CString
      end;
    ap := FileAssociation;
    while ap <> nil do
      begin
        if (ap^.IntName <> nil) and (CStringCaseComp (f^.FilNam, ap^.IntName) = 0) then
          begin
            ap^.IntName := nil;  { Allow `Close (a); Reset (a)' to access next one }
            f^.ExtNam := ap^.ExtName;
            Return f^.ExtNam
          end;
        ap := ap^.Next
      end;
    if IsStdFile (f) then Return nil;
    if f^.Status.FileName then
      begin
        { Derive the external file name from the internal one without asking the user. }
        n := CStringLength (f^.FilNam) + 1;
        Tmp := InternalNew (n);
        Move (f^.FilNam^, Tmp^, n);
        f^.ExtNam := Tmp;
        Return Tmp
      end;
    { Try to write filename prompts to the terminal and try to read responses
      from there also, to avoid messing with Input and Output. However, if
      everything fails, try Input and Output, if they don't work, abort. }
    Tty := OpenHandle (TtyDeviceName, MODE_READ or MODE_WRITE);
    if Tty < 0 then
      begin
        RuntimeWarning ('failed to open terminal for file name read, using Input and Output');
        fin := 0;
        fout := 1
      end
    else
      begin
        fin := Tty;
        fout := Tty
      end;
    case Mode of
      fo_Reset,
      fo_SeekRead:   Buf := 'Input';
      fo_Rewrite,
      fo_SeekWrite:  Buf := 'Output';
      fo_SeekUpdate: Buf := 'Input/Output';
      else           Buf := 'Extend'
    end;
    Buf := Buf + ' file `' + CString2String (f^.FilNam) + ''': ';
    l := Length (Buf);
    if WriteHandle (fout, @Buf[1], l) <> l then
      begin
        if fout <> 1 then RuntimeWarning ('writing file name prompt to ' + TtyDeviceName + ' failed, using Output');
        if (fout = 1) or (WriteHandle (1, @Buf[1], l) <> l) then
          begin
            if Tty >= 0 then Discard (CloseHandle (Tty));
            IOERROR_FILE (419, f, False, '')  { cannot prompt user for external file name for %s }
          end;
        fin := 0
      end;
    SetLength (Buf2, Buf2.Capacity);
    n := ReadHandle (fin, @Buf2[1], Buf2.Capacity);
    if n < 0 then
      begin
        if fin <> 0 then
          begin
            RuntimeWarning ('reading filename from ' + TtyDeviceName + ' failed, trying Input');
            if WriteHandle (1, @Buf[1], l) = l then n := ReadHandle (0, @Buf2[1], Buf2.Capacity)
          end;
        if n < 0 then
          begin
            if Tty >= 0 then Discard (CloseHandle (Tty));
            IOERROR_FILE (420, f, False, '')  { cannot query user for external file name for %s }
          end
      end;
    if Tty >= 0 then Discard (CloseHandle (Tty));
    if (n > 0) and (Buf2[1] = EOT) then
      IOERROR_FILE (421, f, False, '');  { EOT character given for query of file name for %s }
    if (n > 0) and (Buf2[n] = NewLine) then Dec (n);
    Inc (n);
    Buf2[n] := #0;
    Tmp := InternalNew (n);
    Move (Buf2[1], Tmp^, n);
    Slash2OSDirSeparator_CString (Tmp);
    f^.ExtNam := Tmp;
    NameIt := Tmp
  end;

  procedure TryOpen (f: GPC_FDR; FileName: CString; Cond: Boolean; Mode1, Mode2: Integer; Msg: CString);
  var ModeExtra: Integer;
  begin
    ModeExtra := 0;
    {$local R-}  { @@ gcc-2.95.3 mis-compiles range-checking (apparently only
                      here, for some strange reason). On IA32, the output lacks
                      a `testl %edx,%edx' after `cltd' twice (once per
                      statement). The save_expr we add for range-checking seems
                      to cause this (but elsewhere save_expr's work fine. Our
                      playing with TREE_SIDE_EFFECTS does not affect it.
                      Unless we can fix it for 2.95.x (both 2.8.1 and 3.x seem
                      to be ok), just disable range-checking here (the code is
                      not range-critical, anyway) until we drop gcc-2.x
                      ("not EGCS97"). }
    if not f^.Status.Text or ((f^.Binding <> nil) and f^.Binding^.TextBinary) then ModeExtra := ModeExtra or MODE_BINARY;
    if f^.Status.Excl then ModeExtra := ModeExtra or MODE_EXCL;
    {$endlocal}
    if Cond or not f^.Status.ExtB then f^.Handle := OpenHandle (FileName, Mode1 or ModeExtra);
    if (f^.Handle < 0) and (Mode2 >= 0) then
      begin
        f^.Handle := OpenHandle (FileName, Mode2 or ModeExtra);
        if f^.Handle >= 0 then
          begin
            if (Mode2 and MODE_WRITE) = 0 then f^.Status.ROnly := True;
            if (Mode2 and MODE_READ) = 0 then f^.Status.WOnly := True;
            RuntimeWarning (Msg)
          end
      end
  end;

var
  i: Integer;
  TempCloseFlag: Boolean;
  FileName: CString;
  p: PFDRList;
begin
  if InOutRes <> 0 then Exit;
  SaveReturnAddress;
  if (f = nil) or (f^.BufPtr = nil) then InternalError (906);  { InitFDR has not been called for file }
  ResetStatus (f);
  if f^.OpenProc <> DefaultOpenProc then
    begin
      if IsOpen (f) then
        begin
          GPC_Close (f);
          if InOutRes <> 0 then
            begin
              RestoreReturnAddress;
              Exit
            end
        end;
      f^.Handle := -1;
      f^.CloseFlag := True;
      if f^.OpenProc <> nil then f^.OpenProc (f^.PrivateData^, Mode);
      if InOutRes <> 0 then
        begin
          RestoreReturnAddress;
          Exit
        end
    end
  else
    begin
      if (f^.Binding <> nil) and f^.Binding^.Directory then
        begin
          RestoreReturnAddress;
          IOERROR_CSTRING (401, f^.BoundName, False,)  { cannot open directory `%s' }
        end;
      CheckBinding (f);
      if InOutRes <> 0 then
        begin
          RestoreReturnAddress;
          Exit
        end;
      FileName := f^.ExtNam;
      if IsOpen (f) then
        begin
          { f is currently open in Pascal program }
          TempCloseFlag := False;
          { Don't complain when, e.g., the file is "read only" and
            Mode is fo_Rewrite. "Read only" is set for text files on
            Reset regardless whether the file itself is writable.
            Furthermore, the permissions might have been changed
            since the last opening. }
          if f^.Status.ROnly or f^.Status.WOnly then
            TempCloseFlag := True
          else
            begin
              if f^.Status.Extending <> (Mode = fo_Append) then
                begin
                  f^.Status.Extending := Mode = fo_Append;
                  if HaveFCntl then SetFileMode (f^.Handle, MODE_APPEND, f^.Status.Extending)
                end;
              if Mode = fo_Append then
                SeekInternal (f, 0, SeekFileEnd)  { Start appending (maybe redundant, but just to be safe) }
              else if Mode <> fo_Rewrite then
                SeekInternal (f, 0, SeekAbsolute)  { Start reading or updating }
              else
                begin
                  SeekInternal (f, 0, SeekAbsolute);  { Start writing }
                  if TruncateHandle (f^.Handle, 0) < 0 then
                    { If truncation failed (or isn't supported), emulate the behaviour }
                    TempCloseFlag := True
                end
            end;
          if TempCloseFlag then
            begin
              Close1 (f);
              f^.Status.Reading := False;
              f^.Status.Writing := False;
              f^.Status.Extending := False;
              f^.Status.ROnly := False;
              f^.Status.WOnly := False;
              f^.Status.Tty := False;
              if InOutRes <> 0 then
                begin
                  RestoreReturnAddress;
                  Exit
                end
              { Let the code below re-open the same external file for writing.
                If the file is internal, it will not be the same, but who cares. }
            end
        end;

      if not IsOpen (f) then
        begin
          if ((Mode = fo_Reset) or (Mode = fo_SeekRead) or (Mode = fo_SeekUpdate)) and not f^.Status.ExtB then
            begin
              RestoreReturnAddress;
              IOERROR_FILE (436, f, False,)  { `Reset', `SeekUpdate' or `SeekRead' to nonexistent %s }
            end;
          if (f^.Binding <> nil) and (f^.Binding^.Handle >= 0) and (f^.BoundName^ = #0) then
            begin
              f^.Handle := f^.Binding^.Handle;
              f^.CloseFlag := f^.Binding^.CloseFlag
            end
          else
            begin
              if FileName = nil then FileName := NameIt (f, Mode);
              if InOutRes <> 0 then
                begin
                  RestoreReturnAddress;
                  Exit
                end;
              if (FileName = nil) or (FileName^ = #0) or (CString2String (FileName) = '-') then
                begin
                  if Mode = fo_Reset then
                    if CurrentStdInFDR <> nil then
                      f^.Handle := CurrentStdInFDR^.Handle
                    else
                      f^.Handle := 0  { Input }
                  else
                    if f = GPC_StdErr then
                      f^.Handle := 2  { StdErr }
                    else
                      f^.Handle := 1;  { Output }
                  f^.CloseFlag := False  { don't close standard file handles }
                end
              else
                begin
                  { Try to open the file. If it fails, but we only want to read
                    from or write to the file, check if that is possible. }
                  f^.Handle := -1;
                  f^.CloseFlag := True;
                  case Mode of
                    fo_Reset,
                    fo_SeekRead:
                      begin
                        if f^.Status.Text then i := FileMode_Text_Reset_ReadWrite else i := FileMode_Reset_ReadWrite;
                        TryOpen (f, FileName, (FileMode and i) <> 0, MODE_READ or MODE_WRITE, MODE_READ, 'file is read only')
                      end;
                    fo_Rewrite:
                      TryOpen (f, FileName, (FileMode and FileMode_Rewrite_WriteOnly) = 0, MODE_READ or MODE_WRITE or MODE_CREATE or MODE_TRUNCATE,
                        MODE_WRITE or MODE_CREATE or MODE_TRUNCATE, 'file is write only');
                    fo_Append:
                      TryOpen (f, FileName, (FileMode and FileMode_Extend_WriteOnly) = 0, MODE_READ or MODE_WRITE or MODE_CREATE or (MODE_APPEND * Ord (HaveFCntl)),
                        MODE_WRITE or MODE_CREATE or MODE_APPEND, 'file is write only');
                    fo_SeekWrite:
                      TryOpen (f, FileName, True, MODE_READ or MODE_WRITE or MODE_CREATE, MODE_WRITE or MODE_CREATE, 'file is write only');
                    fo_SeekUpdate:
                      TryOpen (f, FileName, True, MODE_READ or MODE_WRITE, -1, '');
                    else
                      InternalError (904)  { invalid file open mode }
                  end
                end
            end;
          if f^.Handle < 0 then
            begin
              FileName := nil;
              RestoreReturnAddress;
              if (Mode >= fo_Reset) and (Mode <= fo_SeekUpdate) then i := OpenErrorCode[Mode] else i := 904;
              IOERROR_FILE (i, f, True,)
            end
          else if not f^.Status.ExtB then
            Unlink (f, FileName, True)
        end;
      CheckFileType (f)
    end;
  f^.Status.Reading := (Mode in [fo_Reset, fo_SeekRead, fo_SeekUpdate]) or not (f^.Status.Text and f^.Status.WOnly);
  f^.Status.Writing := (Mode in [fo_Rewrite, fo_Append, fo_SeekWrite, fo_SeekUpdate]) or not (f^.Status.Text and f^.Status.ROnly);
  f^.Status.Extending := Mode = fo_Append;
  f^.Status.Unread := False;
  ClearBuffer (f);
  f^.Flags := 0;
  { Add to FDR chain. Do it only when necessary, to speed up e.g. the string TFDD }
  if (f^.FlushProc <> nil) or (f^.CloseProc <> nil) or (f^.DoneProc <> nil) then
    begin
      p := FDRList;
      while (p <> nil) and (p^.Item <> f) do p := p^.Next;
      if p = nil then  { f not yet in list }
        begin
          p := InternalNew (SizeOf (p^));
          p^.Next := FDRList;
          p^.Item := f;
          FDRList := p
        end
    end;
  case Mode of
    fo_Append:
      begin
        if f^.Status.Text and { @@ TFDD } (f^.OpenProc = DefaultOpenProc)
           and not ((f^.Binding <> nil) and f^.Binding^.TextBinary) then
          begin
            if f^.Status.WOnly then
              RuntimeWarningCString ('appending to write only text file `%s''; trailing EOLn not checked', f^.FilNam)
            else if SeekInternal (f, -1, SeekFileEnd) then
              begin
                Discard (InternalGetC (f));
                {$ifdef __EMX__}
                Discard (InternalGetC (f));
                {$endif}
                { file pointer is now at EOF }
                if not f^.Status.EOLn then InternalWrite (PChars0 (@NewLineChar), SizeOf (NewLineChar), f)
              end
          end;
        f^.Status.EOF := True;
        f^.Status.LGet := True;
        f^.Status.EOLn := False;
        if { @@ TFDD } (f^.OpenProc = DefaultOpenProc) and not SeekInternal (f, 0, SeekFileEnd) then
          begin
            {$if False}  { @@@@ pipes, ttys? }
            RestoreReturnAddress;
            IOERROR_FILE (416, f, True,)  { `Extend' could not seek to end of % }
            {$endif}
          end
      end;
    fo_Rewrite:
      begin
        f^.Status.EOF := True;
        f^.Status.LGet := True;
        f^.Status.EOLn := False
      end;
    fo_Reset:
      begin
        f^.Status.LGet := True;
        f^.Status.Unread := True;
        f^.Status.EOF := False;
        f^.Status.EOLn := False;
        f^.Status.Undef := False
      end;
  end;
  RestoreReturnAddress
end;

procedure InternalOpen (f: GPC_FDR; FileName: CString; Length: Integer; BufferSize: Integer; Mode: TOpenMode);
begin
  if InOutRes <> 0 then Exit;
  if f^.Status.Untyped then
    begin
      if BufferSize > 0 then
        f^.FilSiz := BufferSize
      else
        IOERROR_FILE (400, f, False,)  { file buffer size of % must be > 0 }
    end;
  { else error, but compiler should not let a bufsize be passed for typed files }
  if FileName <> nil then
    begin
      Internal_Assign (f, FileName, Length);
      if (InOutRes = 0) and ((f^.Binding = nil) or not f^.Binding^.Bound) then
        IOERROR_CSTRING (405, FileName, False,)  { cannot open `%s'' }
    end;
  Open (f, Mode)
end;

procedure Initialize_Std_Files;
const StdFileFlags = fkind_TEXT or fkind_EXTERN or fkind_BINDABLE;
var InitStdFilesDone: Boolean = False; attribute (static);
begin
  if InitStdFilesDone then Exit;
  InitStdFilesDone := True;
  SaveReturnAddress;
  InitFDR (GPC_StdErr, 'StdErr', 1, StdFileFlags); InternalOpen (GPC_StdErr, nil, 0, -1, fo_Rewrite);
  InitFDR (GPC_Output, 'Output', 1, StdFileFlags); InternalOpen (GPC_Output, nil, 0, -1, fo_Rewrite);
  InitFDR (GPC_Input,  'Input',  1, StdFileFlags); InternalOpen (GPC_Input,  nil, 0, -1, fo_Reset);
  RestoreReturnAddress
end;

{ Get FilSiz bytes from the file. }
procedure GetN (f: GPC_FDR);

  procedure InternalRead (Buf: PChars0; Size: SizeType; var PResult: SizeType; f: GPC_FDR);
  var Result, r, i: SizeType;
  begin
    Result := 0;
    i := 0;
    if f^.Status.EOF then Exit;
    while (InOutRes = 0) and (Result < Size) do
      begin
        if f^.BufPos < f^.BufSize then
          begin
            r := Min (f^.BufSize - f^.BufPos, Size - Result);
            Move (f^.BufPtr^[f^.BufPos], Buf^[i], r);
            Inc (f^.BufPos, r);
            Inc (i, r);
            Inc (Result, r)
          end;
        if Result < Size then
          begin
            ReadBuffer (f);
            if f^.BufPos >= f^.BufSize then
              begin
                f^.Status.EOF := True;
                f^.Status.EOLn := True;
                Break
              end
          end
      end;
    if @PResult <> nil then
      PResult := Result
    else if (InOutRes = 0) and (Result <> Size) then
      IOERROR_FILE (465, f, False,)  { cannot read all the data from %s }
  end;

var
  c: Integer;
  n: SizeType;
begin
  if not CheckReadableNotEOF (f) then Exit;
  f^.Status.Undef := False;
  f^.Status.LGet := False;
  { @@ this different treatment is suspicious }
  if f^.FilSiz = 1 then  { no files are packed in GPC }
    begin
      c := InternalGetC (f);
      if c < 0 then
        begin
          f^.Status.EOF := True;
          f^.Status.Undef := True
        end
      else
        f^.FilBuf^[0] := Chr (c);
      Exit
    end;
  InternalRead (f^.FilBuf, f^.FilSiz, n, f);
  if InOutRes <> 0 then Exit;
  if n < f^.FilSiz then
    begin
      if n <> 0 then
        RuntimeWarning ('read partial record in `Get''')
      else
        begin
          f^.Status.EOF := True;
          f^.Status.EOLn := True
        end;
      f^.Status.Undef := True
    end
  else
    f^.Status.LGet := False
end;

{ Because of lazy I/O, each buffer access needs to check
  that the buffer is valid. If not, we need to do a get before
  accessing the buffer.

  When we do a reset or read something from a file, the old method
  needs to read new contents to the buffer before the data is
  actually needeed. This is annoying if you do interactive programs,
  the output to terminal asking for input comes after you have
  already given the input to the program, or you have to code
  things differently for terminals and files, which is also annoying.

  Lazy I/O means that we must not do a `Put' too late, and do a `Get'
  as late as we can. The first condition is satisfied either by not
  buffering output at all, or else flushing output to terminals
  before each get; the second condition is fulfilled when we check
  that the buffer is valid each time we generate buffer references. }

{ This is the buffer referencing routine for read-only access.
  If the file buffer contents is lazy, validate it. }
function LazyGet (f: GPC_FDR): Pointer;
begin
  if (InOutRes = 0) and f^.Status.LGet then
    begin
      GetN (f);
      CheckReadableNotEOF (f)
    end;
  LazyGet := f^.FilBuf
end;

{ Empty a file buffer before writing to it.
  If the file buffer content is filled, clear it and seek back. }
function LazyUnget (f: GPC_FDR): Pointer;
begin
  if (InOutRes = 0) and not f^.Status.LGet then
    begin
      SeekInternal (f, 0, SeekRelative);  { SeekInternal checks and resets the buffer itself }
      f^.Status.EOF := False;
      f^.Status.EOLn := False;
      f^.Status.Undef := True
    end;
  LazyUnget := f^.FilBuf
end;

{ This is the buffer referencing routine. Nothing is done
  if f^.Status.LGet is not set. }
function LazyTryGet (f: GPC_FDR): Pointer;
begin
  if not IsOpen (f) then IOERROR_FILE (453, f, False, f^.FilBuf);  { %s is not open }
  if InOutRes <> 0 then Return f^.FilBuf;
  {$if False}
  { @@ This is called also for `Buffer^ := Val;'
       So it must not blindly trap the reference.
       The compiler should clear the Undef status for these (?) }
  if f^.Status.Undef and not f^.Status.LGet then
    IOERROR_FILE (440, f, False, f^.FilBuf);  { reference to buffer variable of %s with undefined value }
  {$endif}
  { If the file buffer contents is lazy, validate it }
  if f^.Status.LGet then
    if f^.Status.Reading and not f^.Status.EOF then
      begin
        GetN (f);
        { CheckReadableNotEOF (f)  (fails eof1.pas) }
      end
    else
      { Buffer cannot be read in. But perhaps someone only wants to
         write to it, who knows? (This routine doesn't know, and that's
         the problem not )-: So we just mark it as undefined. }
      f^.Status.Undef := True;
  LazyTryGet := f^.FilBuf
end;

{ Get
  pre-assertion:
    (f0.M = Inspection or f0.M = Update) and
    (neither f0.L nor f0.R is undefined) and
    (f0.R <> S ())
  post-assertion:
    (f.M = f0.M) and (f.L = f0.L~S (f0.R.first)) and (f.R = f0.R.rest) and
    (if (f.R = S ()) then
      (f^ is undefined)
    else
      (f^ = f.R.first)) }
procedure GPC_Get (f: GPC_FDR);
begin
  LazyGet (f);
  f^.Status.LGet := True
end;

function GPC_EOF (f: GPC_FDR): Boolean;
begin
  if InOutRes <> 0 then
    GPC_EOF := True
  else if not IsOpen (f) then
    IOERROR_FILE (455, f, False, True)  { `EOF' tested for unopened %s }
  else
    begin
      if not f^.Status.EOF and f^.Status.LGet and f^.Status.Reading then
      GetN (f);
      GPC_EOF := (InOutRes <> 0) or f^.Status.EOF
    end
end;

function GPC_EOLn (f: GPC_FDR): Boolean;
begin
  if InOutRes <> 0 then
    GPC_EOLn := True
  else if not IsOpen (f) then
    IOERROR_FILE (456, f, False, True)  { `EOLn' tested for unopened %s }
  else if not f^.Status.Text then
    IOERROR_FILE (458, f, False, True)  { `EOLn' applied to non-text %s }
  else
    begin
      if not f^.Status.EOF and f^.Status.LGet and f^.Status.Reading then
        begin
          { EOLnResetHack: If EOLn is tested on a terminal device where
            nothing has been read yet, insert an EOLn. }
          if f^.Status.Unread and EOLnResetHack and f^.Status.Tty then
            begin
              f^.FilBuf^[0] := ' ';
              f^.Status.EOLn := True;
              f^.Status.LGet := False;
              f^.Status.Undef := False;
              f^.Status.Unread := False;
              Return True
            end;
          if CheckReadable (f) then GetN (f);
          if InOutRes <> 0 then Return True
        end;
      if f^.Status.EOF then
        GPC_EOLn := True  { IOERROR_FILE (457, f, False, True); }  { `EOLn' tested for %s when `EOF' is True }
      else
        GPC_EOLn := f^.Status.EOLn
    end
end;

function CanRead (var f: GPC_FDR): Boolean;
var e: array [1 .. 1] of IOSelectType = ((f: Pointer (@f), Wanted: [SelectRead]));
begin
  DO_RETURN_ADDRESS (CanRead := IOSelect (e, 0) > 0)
end;

function CanWrite (var f: GPC_FDR): Boolean;
var e: array [1 .. 1] of IOSelectType = ((f: Pointer (@f), Wanted: [SelectWrite]));
begin
  DO_RETURN_ADDRESS (CanWrite := IOSelect (e, 0) > 0)
end;

{ @@ Make Result the return value (affects compiler), somewhat more efficient (also GPC_BlockWrite) }
procedure GPC_BlockRead (f: GPC_FDR; IsAnyFile: Boolean; Buf: PChars0; Count: Cardinal; var Result: Cardinal);
var
  Size, m, n, r: SizeType;
  BufAgain: Boolean;
  e: array [1 .. 1] of IOSelectType = ((f: Pointer (@f), Wanted: [SelectReadOrEOF]));
begin
  if IsAnyFile then Size := 1 else Size := f^.FilSiz;
  if @Result <> nil then Result := 0;
  if (InOutRes <> 0) or not CheckReadable (f) then Exit;
  Count := Count * Size;
  m := 0;
  if not f^.Status.EOF then
    begin
      { If something was read ahead (e.g. in GPC_EOF), copy this to the
        destination buffer first }
      if (Count > 0) and not f^.Status.LGet then
        begin
          { For AnyFiles it might happen that the requested amount of
            data is less than the file buffer size. Discard the rest.
            (There's nothing sensible to do then.) }
          m := Min (f^.FilSiz, Count);
          Move (f^.FilBuf^, Buf^, m);
          Dec (Count, m);
          f^.Status.LGet := True
        end;
      repeat
        begin
          BufAgain := False;
          if (Count > 0) and (f^.BufPos < f^.BufSize) then
            begin
              n := Min (f^.BufSize - f^.BufPos, Count);
              Move (f^.BufPtr^[f^.BufPos], Buf^[m], n);
              Inc (f^.BufPos, n);
              if f^.BufPos >= f^.BufSize then ClearBuffer (f);
              Dec (Count, n);
              Inc (m, n)
            end;
          if Count > 0 then
            begin
              if (m >= Size) and (@Result <> nil) and (IOSelect (e, 0) <= 0) then Break;
              if Count < FileBufSize then
                begin
                  ReadBuffer (f);
                  BufAgain := f^.BufSize > f^.BufPos
                end;
              if not BufAgain then
                begin
                  if f^.Status.Tty then FlushAllFiles;
                  repeat
                    if f^.ReadFunc <> nil then
                      begin
                        if f^.ReadFunc = DefaultReadFunc then
                          n := ReadInternal (f, PChars0 (@Buf^[m]), Count)
                        else
                          begin
                            n := f^.ReadFunc (f^.PrivateData^, Buf^[m], Count);
                            if (InOutRes <> 0) and (InOutResString = nil) then IOERROR_FILE (InOutRes, f, False,)
                          end
                      end
                    else
                      n := 0;
                    Dec (Count, n);
                    Inc (m, n)
                  until (n <= 0) or (Count <= 0) or ((m >= Size) and (@Result <> nil));
                  if n = 0 then f^.Status.EOF := True
                end
            end
        end
      until not BufAgain
    end;
  r := m mod Size;
  if r <> 0 then
    begin
      Move (Buf^[m - r], f^.BufPtr^[f^.BufSize], r);
      Inc (f^.BufSize, r)
    end;
  if @Result <> nil then
    Result := m div Size
  else if Count > 0 then
    IOERROR_FILE (415, f, False,)  { BlockRead: could not read all the data from `%s' }
end;

{ Read an integer number. Actually the result type is LongestInt if Signed is True. }
function Read_IntegerOrCardinal (f: GPC_FDR; Signed: Boolean) = Num: LongestCard;

  function TestDigit (ch: Integer; var Digit: Cardinal; Base: Cardinal): Boolean; attribute (inline);
  begin
    case ch of
      Ord ('0') .. Ord ('9'): Digit := ch - Ord ('0');
      Ord ('A') .. Ord ('Z'): Digit := ch - Ord ('A') + 10;
      Ord ('a') .. Ord ('z'): Digit := ch - Ord ('a') + 10;
      else Digit := Base
    end;
    TestDigit := Digit < Base
  end;

var
  ch, i: Integer;
  Digit, Base: Cardinal;
  BaseChanged, Hex, Negative, Overflow: Boolean;
  NumSigned: LongestInt absolute Num;
begin
  if InOutRes <> 0 then Return 0;
  repeat
    ch := DirectGetCCheckEOF (f);
    if InOutRes <> 0 then Return 0
  until not (ch in OrdSpaceNL);
  i := 552;  { sign or digit expected }
  Overflow := False;
  Negative := False;
  if ch in [Ord ('+'), Ord ('-')] then
    begin
      if ch = Ord ('-') then Negative := True;
      ch := DirectGetCCheckEOF (f);
      if InOutRes <> 0 then Return 0;
      i := 551  { digit expected after sign }
    end;
  Base := 10;
  BaseChanged := False;
  { Check for `$' hex base specifier }
  Hex := (ch = Ord ('$')) and ((f^.Flags and INT_READ_HEX_MASK) <> 0);
  if not (TestDigit (ch, Digit, Base) or Hex) then IOERROR (i, False, 0);
  if Hex then
    begin
      Base := $10;
      BaseChanged := True;
      ch := DirectGetCCheckEOF (f);
      if InOutRes <> 0 then Return 0;
      if not TestDigit (ch, Digit, Base) then IOERROR (557, False, 0)  { digit expected after `$'' in integer constant }
    end;
  { Now ch contains the first digit. Get the integer }
  Num := 0;
  repeat
    begin
      if Num > (High (Num) - Digit) div Base then Overflow := True;
      {$local R-} Num := Num * Base + Digit; {$endlocal}
      ch := DirectGetC (f);
      { Check for `n#' base specifier }
      if (ch = Ord ('#')) and ((f^.Flags and INT_READ_BASE_SPEC_MASK) <> 0) then
        begin
          if BaseChanged then IOERROR (559, False, 0);  { only one base specifier allowed in integer constant }
          if (Num < 2) or (Num > 36) then IOERROR (560, False, 0);  { base out of range (2 .. 36) }
          Base := Num;
          BaseChanged := True;
          Num := 0;
          ch := DirectGetCCheckEOF (f);
          if InOutRes <> 0 then Return 0;
          if not TestDigit (ch, Digit, Base) then IOERROR (558, False, 0)  { digit expected after `#'' in integer constant }
        end
    end
  until not TestDigit (ch, Digit, Base);
  if ((f^.Flags and NUM_READ_CHK_WHITE_MASK) <> 0) and not ((ch < 0) or (ch in OrdSpaceNL)) then IOERROR (561, False, 0);  { invalid digit }
  UnGetCh (f, ch);
  if ((f^.Flags and VAL_MASK) <> 0) and (f^.BufPos - Ord (not f^.Status.LGet) < f^.BufSize) then
    begin
      Inc (f^.BufPos);
      InOutRes := ValInternalError
    end;
  if not Signed then
    begin
      if Negative and (Num <> 0) then Overflow := True
    end
  else
    if Negative then
      begin
        if Num > -Low (NumSigned) then Overflow := True;
        {$local R-}
        NumSigned := -NumSigned
        {$endlocal}
      end
    else
      if Num > High (NumSigned) then Overflow := True;
  if Overflow then IOERROR (553, False, 0)  { overflow while reading integer }
end;

function Read_Integer (f: GPC_FDR): LongestInt;
begin
  Read_Integer := {$local R-} LongestInt (Read_IntegerOrCardinal (f, True)) {$endlocal}
end;

function Read_Cardinal (f: GPC_FDR): LongestCard;
begin
  Read_Cardinal := Read_IntegerOrCardinal (f, False)
end;

{ Check if two real numbers are approximately equal }
function RealEQ (x, y: LongReal): Boolean; attribute (inline);
begin
  RealEQ := Abs (x - y) <= Abs (1.0e-6 * x)
end;

procedure CheckRealOverUnderflow (Tmp, p: LongReal); attribute (inline);
begin
  if InOutRes <> 0 then Exit;
  if {$local W no-float-equal} (p = 0) and (Tmp <> 0) {$endlocal} then IOERROR (564, False,);  { underflow while reading real number }
  if ((Tmp < -1) or (Tmp > 1)) and not RealEQ (Tmp, p) then IOERROR (563, False,)  { overflow while reading real number }
end;

{ Unless REAL_READ_SP_ONLY_MASK is set, accept the Extended Pascal
  real number format extension:
  [ sign ] (digit-sequence [ "." ] | "." fractional-part) [ "e" scale-factor ] }
function Read_LongReal (f: GPC_FDR): LongReal;
const OrdDigits = [Ord ('0') .. Ord ('9')];
var
  Negative, RequireFractional, ENegative: Boolean;
  Expon, LastExpon, ch, i: Integer;
  Val, LastVal, Frac: LongReal;
begin
  if InOutRes <> 0 then Return 0;
  repeat
    ch := DirectGetCCheckEOF (f);
    if InOutRes <> 0 then Return 0
  until not (ch in OrdSpaceNL);
  i := 552;  { sign or digit expected }
  Negative := False;
  if ch in [Ord ('+'), Ord ('-')] then
    begin
      if ch = Ord ('-') then Negative := True;
      repeat
        ch := DirectGetCCheckEOF (f);
        if InOutRes <> 0 then Return 0
      until not (ch in OrdSpaceNL);  { skip spaces between sign and digit or dot }
      if (f^.Flags and REAL_READ_SP_ONLY_MASK) <> 0 then
        i := 551  { digit expected after sign }
      else
        i := 562  { digit or `.'' expected after sign }
    end;
  if not ((ch in OrdDigits) or ((ch = Ord ('.')) and ((f^.Flags and REAL_READ_SP_ONLY_MASK) = 0))) then IOERROR (i, False, 0);
  RequireFractional := ((f^.Flags and REAL_READ_SP_ONLY_MASK) <> 0) or not (ch in OrdDigits);
  Val := 0;
  { Read the mantissa. ch is now a digit or '.' }
  while ch in OrdDigits do
    begin
      LastVal := Val;
      Val := 10 * Val + (ch - Ord ('0'));
      if not RealEQ ((Val - (ch - Ord ('0'))) / 10, LastVal) then IOERROR (563, False, 0);  { overflow while reading real number }
      ch := DirectGetC (f)
    end;
  if ch = Ord ('.') then
    begin
      { Read the fractional part }
      ch := DirectGetC (f);
      if RequireFractional and not (ch in OrdDigits) then IOERROR (554, False, 0);  { digit expected after decimal point }
      Frac := 1;
      while ch in OrdDigits do
        begin
          Frac := Frac / 10;
          Inc (Val, Frac * (ch - Ord ('0')));
          ch := DirectGetC (f)
        end
    end;
  { Read the exponent }
  if ch in [Ord ('e'), Ord ('E')] then
    begin
      ch := DirectGetCCheckEOF (f);
      if InOutRes <> 0 then Return 0;
      ENegative := False;
      if ch in [Ord ('+'), Ord ('-')] then
        begin
          if ch = Ord ('-') then ENegative := True;
          ch := DirectGetCCheckEOF (f);
          if InOutRes <> 0 then Return 0
        end;
      if not (ch in OrdDigits) then IOERROR (555, False, 0);  { digit expected while reading exponent }
      Expon := 0;
      {$local W no-float-equal}
      while ch in OrdDigits do
        begin
          LastExpon := Expon;
          Expon := 10 * Expon + (ch - Ord ('0'));
          if (Expon - (ch - Ord ('0'))) / 10 <> LastExpon then IOERROR (556, False, 0);  { exponent out of range }
          ch := DirectGetC (f)
        end;
      if Val <> 0 then
        if ENegative then
          begin
            { @@ should do square and divide }
            for i := 1 to Expon do Val := Val / 10;
            if Val = 0 then  { note that Val <> 0 originally }
              IOERROR (556, False, 0)  { exponent out of range }  { @@ or should we just return 0? }
          end
        else
          begin
            { @@ should do square and multiply }
            for i := 1 to Expon do Val := Val * 10;
            if IsInfinity (Val) or IsNotANumber (Val) then IOERROR (556, False, 0)  { exponent out of range }
          end
      {$endlocal}
    end;
  if ((f^.Flags and NUM_READ_CHK_WHITE_MASK) <> 0) and not ((ch < 0) or (ch in OrdSpaceNL)) then IOERROR (561, False, 0);  { invalid digit }
  UnGetCh (f, ch);
  if ((f^.Flags and VAL_MASK) <> 0) and (f^.BufPos - Ord (not f^.Status.LGet) < f^.BufSize) then
    begin
      Inc (f^.BufPos);
      InOutRes := ValInternalError
    end;
  if Negative then
    Read_LongReal := -Val
  else
    Read_LongReal := Val
end;

function Read_ShortReal (f: GPC_FDR): ShortReal;
var
  Tmp: LongReal;
  p: ShortReal; attribute (volatile);
begin
  Tmp := Read_LongReal (f);
  p := Tmp;
  CheckRealOverUnderflow (Tmp, p);
  if (InOutRes <> 0) and (InOutRes <> ValInternalError) then Read_ShortReal := 0 else Read_ShortReal := p
end;

function Read_Real (f: GPC_FDR): Real;
var
  Tmp: LongReal;
  p: Real; attribute (volatile);
begin
  Tmp := Read_LongReal (f);
  p := Tmp;
  CheckRealOverUnderflow (Tmp, p);
  if (InOutRes <> 0) and (InOutRes <> ValInternalError) then Read_Real := 0 else Read_Real := p
end;

function Read_Char (f: GPC_FDR): Char;
var i: Integer;
begin
  if InOutRes <> 0 then
    Read_Char := ' '
  else
    begin
      i := DirectGetCCheckEOF (f);
      if i < 0 then Read_Char := ' ' else Read_Char := Chr (i)
    end
end;

function Read_Word (f: GPC_FDR) = Res: TString;
var ch: Integer;
begin
  Res := '';
  if InOutRes <> 0 then Exit;
  repeat
    ch := DirectGetCCheckEOF (f);
    if InOutRes <> 0 then Exit
  until not (ch in OrdSpaceNL);
  repeat
    Insert (Chr (ch), Res, Length (Res) + 1);
    ch := DirectGetC (f)
  until not (ch in [Ord ('A') .. Ord ('Z'), Ord ('a') .. Ord ('z'), Ord ('0') .. Ord ('9'), Ord ('_')]);
  UnGetCh (f, ch)
end;

function Read_Boolean (f: GPC_FDR): Boolean;
var v: TString;
begin
  v := Read_Word (f);
  Read_Boolean := False;
  if InOutRes <> 0 then Exit;
  if StrEqualCase (v, TrueString) then
    Read_Boolean := True
  else if not StrEqualCase (v, FalseString) then
    IOERROR (565, False, False)  { invalid Boolean value read }
end;

function Read_Enum (f: GPC_FDR; IDs: array of PString) = Res: Integer;
var v: TString;
begin
  v := Read_Word (f);
  Res := 0;
  if InOutRes <> 0 then Exit;
  while (Res <= High (IDs)) and not StrEqualCase (v, IDs[Res]^) do Inc (Res);
  if Res > High (IDs) then IOERROR (566, False, 0)  { invalid enumaration value read }
end;

{ Read a string up to the capacity or a newline, whichever comes first.
  Return the number of characters read. }
function Read_String (f: GPC_FDR; Str: PChars0; Capacity: Integer) = Length: Integer;
var ch: Integer;
begin
  Length := 0;
  if InOutRes <> 0 then Exit;
  if ((f^.Flags and READ_STRING_MASK) = 0) and not CheckReadableNotEOF (f) then Exit;
  if Capacity < 0 then InternalError (901);  { string capacity cannot be negative }
  { If EOLn (f) is True, nothing is read and Length is left zero. }
  if not f^.Status.EOLn then
    while Length < Capacity do
      begin
        ch := DirectGetC (f);
        if (ch < 0) or f^.Status.EOLn then
          begin
            UnGetCh (f, ch);
            Break
          end;
        Str^[Length] := Chr (ch);
        Inc (Length)
      end
end;

procedure Read_FixedString (f: GPC_FDR; Str: PChars0; Capacity: Integer);
var Length: Integer;
begin
  Length := Read_String (f, Str, Capacity);
  for Length := Length to Capacity - 1 do Str^[Length] := ' '  { fill with spaces }
end;

procedure Read_Line (f: GPC_FDR);
begin
  if (InOutRes = 0) and f^.Status.Reading and f^.Status.EOF and not f^.Status.LastEOLn then
    begin
      f^.Status.LastEOLn := True;
      Exit
    end;
  if not CheckReadableNotEOF (f) then Exit;
  while not (f^.Status.EOF or f^.Status.EOLn) do GetN (f);
  { Now EOLn is not True because we just read it off }
  if f^.Status.EOF then f^.Status.LastEOLn := True;
  f^.Status.EOLn := False;
  f^.Status.LGet := True
end;

procedure Read_Init (f: GPC_FDR; Flags: Integer);
begin
  f^.Flags := Flags;
  CheckReadable (f)
end;

function GetReadWriteStrFDR = f: GPC_FDR;
begin
  if LastReadWriteStrFDR <> nil then
    begin
      f := LastReadWriteStrFDR;
      LastReadWriteStrFDR := nil
    end
  else
    f := InternalNew (SizeOf (f^))
end;

function ReadStr_Init (s: PChars0; Length: Cardinal; aFlags: Integer) = f: GPC_FDR;
begin
  if (aFlags and VAL_MASK) <> 0 then StartTempIOError;
  f := GetReadWriteStrFDR;
  ClearStatus (f);
  with f^ do
    begin
      BufPtr := s;
      BufSize := Length;
      BufPos := 0;
      Flags := aFlags or READ_STRING_MASK;
      FilBuf := PChars0 (@InternalBuffer)  { only 1 char is actually needed }
    end;
  f^.Status.LGet := True;
  f^.Status.Text := True;
  f^.Status.Reading := True;
  f^.Status.ROnly := True;
  if f^.BufPos >= f^.BufSize then
    begin
      f^.Status.EOF := True;
      f^.Status.EOLn := True
    end
end;

procedure ReadWriteStr_Done (f: GPC_FDR);
begin
  if LastReadWriteStrFDR <> nil then
    InternalDispose (f)
  else
    LastReadWriteStrFDR := f
end;

function Val_Done (f: GPC_FDR): Integer;
var
  Pos: Integer;
  IsEOF: Boolean;
begin
  IsEOF := f^.Status.EOF;
  Pos := f^.BufPos - Ord (not f^.Status.LGet);
  ReadWriteStr_Done (f);
  if (EndTempIOError = 0) and IsEOF then
    Val_Done := 0
  else if Pos = 0 then
    Val_Done := 1
  else
    Val_Done := Pos
end;

procedure WriteToBuf (f: GPC_FDR; const s: String; Size: SizeType);
var i, a: SizeType;
begin
  a := f^.BufSize - f^.BufPos;
  if (a < Size) and ((f^.Flags and FORMAT_STRING_MASK) <> 0) then
    begin
      while f^.BufSize - f^.BufPos < Size do f^.BufSize := f^.BufSize * 2;
      a := f^.BufSize - f^.BufPos;
      ReAllocMem (f^.BufPtr, f^.BufSize)
    end;
  if Size < a then a := Size;
  i := 1;
  if a > 0 then
    begin
      Move (s[i], f^.BufPtr^[f^.BufPos], a);
      Inc (f^.BufPos, a);
      Inc (i, a);
      Dec (Size, a)
    end;
  if Size = 0 then Exit;
  if (f^.Flags and WRITE_STRING_MASK) <> 0 then
    if (f^.Flags and TRUNCATE_STRING_MASK) <> 0 then
      Exit
    else
      IOERROR (584, False,);  { string capacity exceeded in `WriteStr' }
  if InOutRes <> 0 then Exit;
  InternalWrite (f^.BufPtr, f^.BufPos, f);
  if Size <= f^.BufSize then
    begin
      Move (s[i], f^.BufPtr^, Size);
      f^.BufPos := Size
    end
  else
    begin
      InternalWrite (PChars0 (@s[i]), Size, f);
      f^.BufPos := 0
    end
end;

procedure FormatString_StartItem (f: GPC_FDR);
begin
  if f^.FormatStringN <> 0 then
    begin
      f^.FormatStringStrings^[f^.FormatStringN - 1] := f^.BufPtr;
      f^.FormatStringLengths^[f^.FormatStringN - 1] := f^.BufPos
    end;
  if f^.FormatStringN < f^.FormatStringCount then Inc (f^.FormatStringN);
  ClearStatus (f);
  f^.BufSize := 64;  { initial size }
  f^.BufPtr := InternalNew (f^.BufSize);
  f^.BufPos := 0
end;

procedure WritePadded (f: GPC_FDR; const s: String; Width: Integer; Clip: Boolean);

  procedure WritePad (f: GPC_FDR; Count: Integer); attribute (inline);
  const Blanks: String (32) = '                                ';
  begin
    while Count > 0 do
      begin
        WriteToBuf (f, Blanks, Min (Count, Length (Blanks)));
        Dec (Count, Length (Blanks))
      end
  end;

var Size, AbsWidth, PadLeft, PadRight, Pad: Integer;
begin
  if (f^.Flags and FORMAT_STRING_MASK) <> 0 then FormatString_StartItem (f);
  Size := Length (s);
  PadLeft := 0;
  PadRight := 0;
  if Width <> Low (Integer) then
    begin
      AbsWidth := Abs (Width);
      if Size > AbsWidth then
        begin
          Pad := 0;
          if Clip then Size := AbsWidth
        end
      else
        Pad := AbsWidth - Size;
      if (Width <= 0) and ((f^.Flags and NEG_ZERO_WIDTH_ERROR_MASK) <> 0) then
        IOERROR (581, False,)  { fixed field Width must be positive }
      else if Width >= 0 then
        PadLeft := Pad
      else
        case f^.Flags and (NEG_WIDTH_ERROR_MASK or NEG_WIDTH_LEFT_MASK or NEG_WIDTH_CENTER_MASK) of
          NEG_WIDTH_ERROR_MASK:  IOERROR (580, False,);  { fixed field width cannot be negative }
          NEG_WIDTH_LEFT_MASK:   PadRight := Pad;
          NEG_WIDTH_CENTER_MASK: begin
                                   PadLeft := Pad div 2;
                                   PadRight := Pad - PadLeft
                                 end;
        end
    end;
  WritePad (f, PadLeft);
  WriteToBuf (f, s, Size);
  WritePad (f, PadRight)
end;

{$define DEFWRITEINT(Func, VType, UnsignedType, Negative)
procedure Func (f: GPC_FDR; Num: VType; Width: Integer);
var
  n: UnsignedType;
  BufPos: Integer;
  s: array [1 .. MaxLongestIntWidth] of Char;
begin
  BufPos := High (s) + 1;
  if Negative then n := -Num else n := Num;
  repeat
    Dec (BufPos);
    s[BufPos] := Succ ('0', n mod 10);
    n := n div 10
  until n = 0;
  if Negative then
    begin
      Dec (BufPos);
      s[BufPos] := '-'
    end;
  WritePadded (f, s[BufPos .. High (s)], Width, False)
end;}
{$local R-}  { @@ only for `n := -Num', but currently not possible within a macro }
DEFWRITEINT (Write_Integer,  Integer,  Cardinal, Num < 0)
DEFWRITEINT (Write_LongInt,  LongInt,  LongCard, Num < 0)
DEFWRITEINT (Write_Cardinal, Cardinal, Cardinal, False)
DEFWRITEINT (Write_LongCard, LongCard, LongCard, False)
{$endlocal}

procedure Write_Real (f: GPC_FDR; x: LongReal; Width, Precision: Integer);
var
  FirstChar, ExpSign: Char;
  BufPos, TempPos, Count, Exp0, Exp, ExpBufPos, DigitsLeft, DigitsRight, i: Integer;
  AddExp: Boolean;
  v, DigitVal: LongReal;
  Res: PString;
  ExpBuf: array [1 .. MaxLongestIntWidth + 3] of Char;

  procedure ExpPut (ch: Char); attribute (inline);
  begin
    Dec (ExpBufPos);
    ExpBuf[ExpBufPos] := ch
  end;

  function GetDigit: Char; attribute (inline);
  var Digit: Integer;
  begin
    { Do to the inexactness of floating point numbers, the digit computed
      could become 10. Assume 9 here (which will leave the remainder so
      big that the same will happen to subsequent digits as well) and let
      the rounding further down fix it. }
    Digit := Min (9, Trunc (v / DigitVal));
    v := (v - Digit * DigitVal) * 10;
    GetDigit := Succ ('0', Digit)
  end;

begin
  if (Precision <= 0) and (Precision <> Low (Integer)) then
    begin
      if (f^.Flags and NEG_ZERO_WIDTH_ERROR_MASK) <> 0 then IOERROR (583, False,);  { fixed real fraction field width must be positive }
      if Precision < 0 then IOERROR (582, False,)  { fixed real fraction field width cannot be negative }
    end;
  Res := nil;
  if IsNotANumber (x) then
    if (Precision < 0) and ((f^.Flags and REAL_NOBLANK_MASK) = 0) then
      Res := @' NaN'
    else
      Res := @'NaN'
  else if IsInfinity (x) then
    if x < 0 then
      Res := @'-Inf'
    else if (Precision < 0) and ((f^.Flags and REAL_NOBLANK_MASK) = 0) then
      Res := @' Inf'
    else
      Res := @'Inf';
  if Res <> nil then
    begin
      WritePadded (f, Res^, Width, False);
      Exit
    end;

  { Check if there must be a leading minus sign or blank. No blank in front
    of positive Reals with precision given according to ISO. }
  if x < 0 then
    begin
      FirstChar := '-';
      x := -x
    end
  else if (Precision < 0) and ((f^.Flags and REAL_NOBLANK_MASK) = 0) then
    FirstChar := ' '
  else
    FirstChar := #0;

  { Find the exponent }
  Exp0 := 0;
  DigitVal := 1;
  if x >= 1 then
    while DigitVal <= x / 10 do
      begin
        DigitVal := DigitVal * 10;
        Inc (Exp0)
      end
  else if (Precision < 0) and {$local W no-float-equal} (x <> 0) {$endlocal} then
    while x < 1 do
      begin
        x := x * 10;
        Dec (Exp0)
      end;

  if Precision < 0 then
    i := Max (RealDefaultDigits, Abs (Width))
  else
    i := Precision + Exp0 + 2;
  var s: array [1 .. i + High (ExpBuf) + 3] of Char;

  { Prepare for a possible second try; see below }
  AddExp := False;
  repeat
    v := x;
    Exp := Exp0;

    { Second try: exponent must be bigger; see below }
    if AddExp then
      begin
        DigitVal := DigitVal * 10;
        Inc (Exp)
      end;

    { Output the exponent to temporary buffer }
    ExpBufPos := High (ExpBuf) + 1;
    if Precision < 0 then
      begin
        if Exp >= 0 then
          ExpSign := '+'
        else
          begin
            ExpSign := '-';
            Exp := -Exp
          end;
        i := Exp;
        repeat
          ExpPut (Succ ('0', i mod 10));
          i := i div 10
        until i = 0;
        { Print at least 2 digits of the exponent because that's "usual" }
        if Exp < 10 then ExpPut ('0');
        ExpPut (ExpSign);
        if (f^.Flags and REAL_CAPITAL_EXP_MASK) <> 0 then ExpPut ('E') else ExpPut ('e')
      end;

    { Determine number of digits to print before and after the (floating) point }
    if Precision < 0 then
      begin
        DigitsLeft := 1;
        if Width = Low (Integer) then
          DigitsRight := RealDefaultDigits
        else
          DigitsRight := Max (1, Abs (Width) - (Ord (FirstChar <> #0) + DigitsLeft + 1 + (High (ExpBuf) + 1 - ExpBufPos)))
      end
    else
      begin
        DigitsLeft := Exp + 1;
        DigitsRight := Precision
      end;

    BufPos := 1;
    if FirstChar <> #0 then
      begin
        s[BufPos] := FirstChar;
        Inc (BufPos)
      end;

    { Output the mantissa }
    for Count := 1 to DigitsLeft do
      begin
        s[BufPos] := GetDigit;
        Inc (BufPos)
      end;
    if DigitsRight > 0 then
      begin
        s[BufPos] := '.';
        Inc (BufPos);
        for Count := 1 to DigitsRight do
          begin
            s[BufPos] := GetDigit;
            Inc (BufPos)
          end
      end;

    { Rounding }
    if v >= 5 * DigitVal then
      begin
        TempPos := BufPos - 1;
        Count := DigitsLeft + DigitsRight;
        while (Count > 0) and (s[TempPos] = '9') do
          begin
            s[TempPos] := '0';
            Dec (TempPos);
            Dec (Count);
            if Count = DigitsLeft then Dec (TempPos)
          end;
        if Count > 0 then
          begin
            Inc (s[TempPos]);
            AddExp := False
          end
        else
          begin
            { If the mantissa was 999.999, and the number must be rounded up,
              we have to start all over with a bigger exponent }
            Assert (not AddExp);
            AddExp := True
          end
      end
    else
      AddExp := False
  until not AddExp;

  { Copy the exponent to the real buffer }
  for Count := ExpBufPos to High (ExpBuf) do
    begin
      s[BufPos] := ExpBuf[Count];
      Inc (BufPos)
    end;
  WritePadded (f, s[1 .. BufPos - 1], Width, False)
end;

procedure Write_Boolean (f: GPC_FDR; b: Boolean; Width: Integer);
begin
  if b then
    WritePadded (f, TrueString, Width, True)
  else
    WritePadded (f, FalseString, Width, True)
end;

procedure Write_Enum (f: GPC_FDR; IDs: array of PString; v, Width: Integer);
var s: PString;
begin
  if (v < 0) or (v > High (IDs)) then
    s := @'invalid enumeration value'
  else
    s := IDs[v];
  WritePadded (f, s^, Width, False)
end;

procedure Write_Char (f: GPC_FDR; ch: Char; Width: Integer);
begin
  WritePadded (f, ch, Width, (f^.Flags and CLIP_STRING_MASK) <> 0)
end;

procedure Write_String (f: GPC_FDR; s: PChars0; Length: Cardinal; Width: Integer);
begin
  if (s = nil) or (Length = 0) then
    WritePadded (f, '', Width, (f^.Flags and CLIP_STRING_MASK) <> 0)
  else
    WritePadded (f, s^[0 .. Length - 1], Width, (f^.Flags and CLIP_STRING_MASK) <> 0)
end;

procedure Write_Line (f: GPC_FDR);
begin
  WriteToBuf (f, NewLineChar, SizeOf (NewLineChar))
end;

procedure Write_Flush (f: GPC_FDR);
begin
  if InOutRes <> 0 then Exit;
  if f^.BufPos <> 0 then InternalWrite (f^.BufPtr, f^.BufPos, f);
  ClearBuffer (f);
  FlushBuffer (f)
end;

procedure Write_Init (f: GPC_FDR; Flags: Integer);
begin
  if InOutRes <> 0 then Exit;
  CheckWritable (f);
  f^.BufSize := FileBufSize;
  f^.BufPos := 0;
  f^.Flags := Flags
end;

function WriteStr_Init (s: PChars0; Capacity, Flags: Integer) = f: GPC_FDR;
begin
  f := GetReadWriteStrFDR;
  ClearStatus (f);
  f^.BufPtr := s;
  f^.BufSize := Capacity;
  f^.BufPos := 0;
  f^.Status.Writing := True;
  f^.Flags := Flags or WRITE_STRING_MASK
end;

function WriteStr_GetLength (f: GPC_FDR): Integer;
var l: SizeType;
begin
  l := f^.BufPos;
  if (f^.Flags and WRITE_FIXED_STRING_MASK) <> 0 then
    for l := l to f^.BufSize - 1 do f^.BufPtr^[l] := ' ';
  ReadWriteStr_Done (f);
  WriteStr_GetLength := l
end;

function FormatString_Init (Flags, Count: Integer) = f: GPC_FDR;
begin
  f := GetReadWriteStrFDR;
  ClearStatus (f);
  f^.BufSize := 0;
  f^.BufPtr := nil;
  f^.BufPos := 0;
  f^.Flags := Flags or WRITE_STRING_MASK or FORMAT_STRING_MASK;
  f^.FormatStringCount := Count;
  f^.FormatStringStrings := InternalNew (Count * SizeOf (f^.FormatStringStrings^[0]));
  f^.FormatStringLengths := InternalNew (Count * SizeOf (f^.FormatStringLengths^[0]));
  f^.FormatStringN := 0;
end;

function FormatString_Result (f: GPC_FDR; Format: Pointer): Pointer;
begin
  if f^.FormatStringN <> f^.FormatStringCount then InternalErrorCString (900, 'FormatString');  { internal error in `%' }
  if f^.FormatStringN <> 0 then
    begin
      f^.FormatStringStrings^[f^.FormatStringN - 1] := f^.BufPtr;
      f^.FormatStringLengths^[f^.FormatStringN - 1] := f^.BufPos
    end;
  FormatString_Result := InternalFormatString (PString (Format)^, f^.FormatStringCount, f^.FormatStringStrings, f^.FormatStringLengths);
  ReadWriteStr_Done (f)
end;

function StringOf_Result (f: GPC_FDR): Pointer;
begin
    if f^.FormatStringN <> f^.FormatStringCount then InternalErrorCString (900, 'StringOf');  { internal error }
  if f^.FormatStringN <> 0 then
    begin
      f^.FormatStringStrings^[f^.FormatStringN - 1] := f^.BufPtr;
      f^.FormatStringLengths^[f^.FormatStringN - 1] := f^.BufPos
    end;
  StringOf_Result := InternalStringOf (f^.FormatStringCount, f^.FormatStringStrings, f^.FormatStringLengths);
  ReadWriteStr_Done (f)
end;

procedure GPC_Page (f: GPC_FDR);
begin
  InternalWrite (PChars0 (@NewPageChar), SizeOf (NewPageChar), f)
end;

{ Put
  pre-assertion:
    (f0.M = Generation or f0.M = Update) and
    (neither f0.L nor f0.R is undefined) and
    (f0.R = S () or f is a direct access file type) and
    (f0^ is not undefined)
  post-assertion:
    (f.M = f0.M) and (f.L = f0.L~S (f0^)) and
    (if f0.R = S () then
      (f.R = S ())
    else
      (f.R = f0.R.rest)) and
      (if (f.R = S ()) or (f0.M = Generation) then
        (f^ is undefined)
      else
        (f^ = f.R.first)) }
procedure GPC_Put (f: GPC_FDR);
begin
  FlushBuffer (f);
  InternalWrite (f^.FilBuf, f^.FilSiz, f);
  { Undef is set if EOF or mode is generation }
  if f^.Status.EOF then f^.Status.Undef := True
end;

{ Note: Extended Pascal defines the following operations only for direct access
  file types:
  SeekRead, SeekWrite, SeekUpdate, Empty, Position, LastPosition, Update

  Direct access files are defined by: `file [IndexType] of type'
  (the `Ord (a)' in comments means the smallest value of IndexType).

  However, GPC allows the operations also to other files capable of seeking
  (with an optional warning). These non-direct access files may be thought of
  as the following direct access file type: `file [0 .. MaxInt] of <type>' }

{ SeekRead
  pre-assertion:
    (neither f0.L nor f0.R is undefined) and
    (0 <= Ord (n) - Ord (a) <= Length (f0.L~f0.R))
  post-assertion:
    (f.M = Inspection) and (f.L~f.R = f0.L~f0.R) and
    (if Length (f0.L~f0.R) > Ord (n) - Ord (a) then
      ((Length (f.L) = Ord (n) - Ord (a)) and (f^ = f.R.first))
    else
      ((f.R = S () and f^ is undefined)))
  NewPlace is an offset from zero to the correct location. }
procedure GPC_SeekRead (f: GPC_FDR; NewPlace: FileSizeType);
begin
  if InOutRes <> 0 then Exit;
  if NewPlace < 0 then
    IOERROR_FILE (410, f, False,);  { attempt to access elements before beginning of random access % }
  if not IsOpen (f) or f^.Status.Extending then
    begin
      Open (f, fo_SeekRead);
      if InOutRes <> 0 then Exit
    end;
  if not SeekInternal (f, NewPlace, SeekAbsolute) then IOERROR_FILE (427, f, True,);  { `SeekRead' failed on % }
  { change mode to inspection }
  f^.Status.Reading := True;
  f^.Status.Writing := False;
  f^.Status.Extending := False;
  f^.Status.EOF := False;
  f^.Status.LGet := True
end;

{ SeekWrite
  pre-assertion:
    (neither f0.L nor f0.R is undefined) and
    (0 <= Ord (n) - Ord (a) <= Length (f0.L~f0.R))
  post-assertion:
    (f.M = Generation) and (f.L~f.R = f0.L~f0.R) and
    (Length (f.L) = Ord (n) - Ord (a)) and (f^ is undefined)
  Note: this definition does not write anything. It just moves the
  file pointer and changes the mode to generation.
  NewPlace is an offset from zero to the correct location. }
procedure GPC_SeekWrite (f: GPC_FDR; NewPlace: FileSizeType);
begin
  if InOutRes <> 0 then Exit;
  if NewPlace < 0 then
    IOERROR_FILE (410, f, False,);  { attempt to access elements before beginning of random access % }
  if not IsOpen (f) or f^.Status.Extending then
    begin
      Open (f, fo_SeekWrite);
      if InOutRes <> 0 then Exit
    end;
  if not SeekInternal (f, NewPlace, SeekAbsolute) then IOERROR_FILE (429, f, True,);  { `SeekWrite' failed on % }
  { change mode to generation }
  f^.Status.Reading := False;
  f^.Status.Writing := True;
  f^.Status.Extending := False
end;

{ SeekUpdate
  pre-assertion:
    (neither f0.L nor f0.R is undefined) and
    (0 <= Ord (n) - Ord (a) <= Length (f0.L~f0.R))
  post-assertion:
    (f.M = Update) and (f.L~f.R = f0.L~f0.R) and
    (if Length (f0.L~f0.R) > Ord (n) - Ord (a) then
      ((Length (f.L) = Ord (n) - Ord (a)) and
       (f^ = f.R.first))
    else
      ((f.R = S ()) and (f^ is undefined)))
  The (only) difference to SeekRead is that this leaves f.M in update mode. }
procedure GPC_SeekUpdate (f: GPC_FDR; NewPlace: FileSizeType);
begin
  if InOutRes <> 0 then Exit;
  if NewPlace < 0 then
    IOERROR_FILE (410, f, False,);  { attempt to access elements before beginning of random access % }
  if not IsOpen (f) or f^.Status.Extending then
    begin
      Open (f, fo_SeekUpdate);
      if InOutRes <> 0 then Exit
    end;
  if not SeekInternal (f, NewPlace, SeekAbsolute) then IOERROR_FILE (431, f, True,);  { `SeekUpdate' failed on % }
  f^.Status.Reading := True;
  f^.Status.Writing := True;
  f^.Status.Extending := False;
  f^.Status.EOF := False;
  f^.Status.LGet := True
end;

procedure GPC_Seek (f: GPC_FDR; NewPlace: FileSizeType);
begin
  if InOutRes <> 0 then Exit;
  if not f^.Status.Writing then
    GPC_SeekRead (f, NewPlace)
  else if not f^.Status.Reading then
    GPC_SeekWrite (f, NewPlace)
  else
    GPC_SeekUpdate (f, NewPlace)
end;

{ Update
  pre-assertion:
    (f0.M = Generation or f0.M = Update) and
    (neither f0.L nor f0.R is undefined) and
    (f is a direct access file type) and
    (f0^ is not undefined)
  post-assertion:
    (f.M = f0.M) and (f.L = f0.L) and
    (if f0.R = S () then
      (f.R = S (f0^))
    else
      (f.R = S (f0^)~f0.R.rest)) and
    (f^ = f0^)
  i.e. write the stuff to the file, and leave it also in the file buffer.
  Don't advance the file pointer! }
procedure GPC_Update (f: GPC_FDR);
begin
  if InOutRes <> 0 then Exit;
  {$if False}
  { @@ Currently assigning a value to a file buffer does not clear the Undef status.
       Disable this check => Undefined file buffers may be written with update.
       This is related to general undefined variable checks (hard). }
  if f^.Status.Undef then IOERROR_FILE (439, f, False,);  { `Update' with an undefined file buffer in % }
  {$endif}
  if f^.Status.Extending and HaveFCntl then SetFileMode (f^.Handle, MODE_APPEND, False);
  SeekInternal (f, 0, SeekRelative);  { Seek back possible buffered data }
  InternalWrite (f^.FilBuf, f^.FilSiz, f);
  if f^.Status.Extending and HaveFCntl then SetFileMode (f^.Handle, MODE_APPEND, True);
  { The file buffer is still f0^ }
  f^.Status.LGet := False;
  f^.Status.Undef := False
end;

{ Position (f) := Succ (a, Length (f.L))
  This function returns the element number, always counted from zero
  (since the RTS does not know the lower bound of the direct access
  file type), and the compiler adds the lower bound. }
function GPC_Position (f: GPC_FDR) = Pos: FileSizeType;
var NumBytes: FileSizeType;
begin
  if InOutRes <> 0 then Return 0;
  if not IsOpen (f) then IOERROR_FILE (407, f, False, 0);  { % has not been opened }
  NumBytes := SeekHandle (f^.Handle, 0, SeekRelative);
  if NumBytes < 0 then IOERROR_FILE (417, f, True, 0);  { `Position' or `FilePos' could not get file position of % }
  if f^.BufPos < f^.BufSize then Dec (NumBytes, f^.BufSize - f^.BufPos);
  Pos := NumBytes div f^.FilSiz;
  if not (f^.Status.Undef or f^.Status.LGet) then Dec (Pos)
end;

function GPC_FileSize (f: GPC_FDR): FileSizeType;
var OrigPos, LastPos: FileSizeType;
begin
  if InOutRes <> 0 then Return 0;
  if not IsOpen (f) then IOERROR_FILE (407, f, False, 0);  { % has not been opened }
  FlushBuffer (f);
  OrigPos := SeekHandle (f^.Handle, 0, SeekRelative);
  LastPos := -1;
  if OrigPos >= 0 then
    begin
      LastPos := SeekHandle (f^.Handle, 0, SeekFileEnd);
      Discard (SeekHandle (f^.Handle, OrigPos, SeekAbsolute))
    end;
  if LastPos >= 0 then
    GPC_FileSize := LastPos div f^.FilSiz
  else
    IOERROR_FILE (446, f, True, 0)  { cannot get the size of % }
end;

function GPC_LastPosition (f: GPC_FDR): FileSizeType;
begin
  GPC_LastPosition := GPC_FileSize (f) - 1
end;

function GPC_Empty (f: GPC_FDR): Boolean;
begin
  if InOutRes <> 0 then
    GPC_Empty := True
  else
    GPC_Empty := GPC_FileSize (f) = 0
end;

{ DefineSize (GPC extension): Define files size as count of its
  component type units. May be applied only to random access files
  and files opened for writing. }
procedure GPC_DefineSize (f: GPC_FDR; NewSize: FileSizeType);
begin
  if InOutRes <> 0 then Exit;
  if NewSize < 0 then
    IOERROR (437, False,)  { new file size in `DefineSize' is < 0 }
  else if not IsOpen (f) then
    IOERROR_FILE (407, f, False,)  { % has not been opened }
  else if f^.Status.ROnly then
    IOERROR_FILE (438, f, False,);  { `Truncate' or `DefineSize' applied to read only % }
  if InOutRes <> 0 then Exit;
  ClearBuffer (f);
  if TruncateHandle (f^.Handle, NewSize * f^.FilSiz) < 0 then
    { @@ emulate by copying and renaming? }
    IOERROR_FILE (425, f, True,)  { truncation failed for % }
end;

procedure GPC_Truncate (f: GPC_FDR);
begin
  if (InOutRes = 0) and IsOpen (f) then GPC_DefineSize (f, GPC_Position (f))
end;

{ Get the external file name }
function FileName (protected var f: GPC_FDR): TString;
begin
  FileName := CString2String (f^.ExtNam)
end;

function GetErrorMessageFileName (protected var f: GPC_FDR): TString;
begin
  if IsStdFile (f) then
    GetErrorMessageFileName := CString2String (f^.FilNam)
  else if f^.ReadFunc <> DefaultReadFunc then
    GetErrorMessageFileName := 'TFDD file `' + CString2String (f^.FilNam) + ''''
  else if (f^.Binding <> nil) and (f^.Binding^.Handle >= 0) and (f^.BoundName^ = #0) then
    GetErrorMessageFileName := 'file `' + CString2String (f^.FilNam) + ''' bound to file handle #' + Integer2String (f^.Binding^.Handle)
  else if f^.Status.ExtB then
    GetErrorMessageFileName := 'file `' + CString2String (f^.ExtNam) + ''''
  else if f^.Status.Extern then
    GetErrorMessageFileName := 'file `' + CString2String (f^.FilNam) + ''''
  else
    GetErrorMessageFileName := 'internal file `' + CString2String (f^.FilNam) + ''''
end;

procedure IOErrorFile (n: Integer; protected var f: GPC_FDR; ErrNoFlag: Boolean);
begin
  IOErrorCString (n, GetErrorMessageFileName (f), ErrNoFlag)
end;

procedure GPC_Erase (f: GPC_FDR);
begin
  if InOutRes <> 0 then Exit;
  if (f^.Binding <> nil) and f^.Binding^.Directory then IOERROR_CSTRING (473, f^.BoundName, False,);  { `Erase' cannot erase directory `%s' }
  DO_RETURN_ADDRESS (CheckBinding (f));
  if InOutRes <> 0 then Exit;
  if not f^.Status.ExtB then IOERROR_FILE (468, f, False,);  { cannot erase %s }
  if f^.ExtNam = nil then IOERROR_CSTRING (469, f^.FilNam, False,);  { `Erase': external file `%s' has no external name }
  { if IsOpen (f) then IOERROR_FILE (470, f, False,); } { cannot erase opened %s }
  { Only allow delayed unlinking if the file is opened, otherwise a real error
    (e.g., erasing a nonexisting file) could lead to later erasing or strange errors. }
  Unlink (f, f^.ExtNam, IsOpen (f))
end;

procedure FileMove (var f: GPC_FDR; NewName: CString; Overwrite: Boolean);
var
  n: Integer;
  s: CString;
begin
  if InOutRes <> 0 then Exit;
  DO_RETURN_ADDRESS (CheckBinding (f));
  if InOutRes <> 0 then Exit;
  if not f^.Status.ExtB then IOERROR_FILE (475, f, False,);  { cannot rename %s }
  if f^.ExtNam = nil then IOERROR_CSTRING (476, f^.FilNam, False,);  { `Rename/FileMove': external file `%s' has no external name }
  { if IsOpen (f) then IOERROR_FILE (477, f, False,); } { cannot rename opened %s }
  if not Overwrite and (Access (NewName, MODE_FILE) <> 0) then IOERROR_CSTRING (482, NewName, False,);  { `Rename': cannot overwrite file `%s' }
  if CStringRename (f^.ExtNam, NewName) <> 0 then IOERROR_FILE (481, f, True, );  { error when trying to rename %s }
  InternalDispose (f^.ExtNam);
  n := CStringLength (NewName) + 1;
  s := InternalNew (n);
  Move (NewName^, s^, n);
  f^.ExtNam := s;
  if f^.Binding <> nil then f^.BoundName := f^.ExtNam
end;

procedure ChMod (var f: GPC_FDR; Mode: Integer);
begin
  if InOutRes <> 0 then Exit;
  DO_RETURN_ADDRESS (CheckBinding (f));
  if InOutRes <> 0 then Exit;
  { @@ TFDD }
  if f^.ExtNam = nil then IOERROR_CSTRING (491, f^.FilNam, False,);  { `ChMod': file `%s' has no external name }
  if CStringChMod (f^.ExtNam, Mode) <> 0 then IOERROR_FILE (494, f, True,)  { error when trying to change mode of %s }
end;

procedure ChOwn (var f: GPC_FDR; Owner, Group: Integer);
begin
  if InOutRes <> 0 then Exit;
  DO_RETURN_ADDRESS (CheckBinding (f));
  if InOutRes <> 0 then Exit;
  { @@ TFDD }
  if f^.ExtNam = nil then IOERROR_CSTRING (498, f^.FilNam, False,);  { `ChOwn': file `%s' has no external name }
  if CStringChOwn (f^.ExtNam, Owner, Group) <> 0 then IOERROR_FILE (499, f, True,)  { error when trying to change owner of %s }
end;

procedure SetFileTime (f: GPC_FDR; AccessTime: UnixTimeType; ModificationTime: UnixTimeType);
begin
  if InOutRes <> 0 then Exit;
  DO_RETURN_ADDRESS (CheckBinding (f));
  if InOutRes <> 0 then Exit;
  if not f^.Status.ExtB or (f^.ExtNam = nil) then IOERROR_CSTRING (486, f^.FilNam, False,);  { `SetFTime': file `%s' has no external name }
  if CStringUTime (f^.ExtNam, AccessTime, ModificationTime) <> 0 then IOERROR_FILE (487, f, True,)  { cannot set time for %s }
end;

function FileLock (var f: GPC_FDR; WriteLock, Block: Boolean): Boolean;
begin
  FileLock := LockHandle (f^.Handle, WriteLock, Block)
end;

function FileUnlock (var f: GPC_FDR): Boolean;
begin
  FlushBuffer (f);
  FileUnlock := UnlockHandle (f^.Handle)
end;

function MemoryMap (Start: Pointer; Length: SizeType; Access: Integer; Shared: Boolean; var f: GPC_FDR; Offset: FileSizeType): Pointer;
begin
  MemoryMap := MMapHandle (Start, Length, Access, Shared, f^.Handle, Offset)
end;

procedure MemoryUnMap (Start: Pointer; Length: SizeType);
begin
  if MUnMapHandle (Start, Length) <> 0 then IOERROR (409, True,)  { cannot unmap memory }
end;

procedure AssignFile (var t: AnyFile; const FileName: String);
var b: BindingType;
begin
  Unbind (t);
  b := Binding (t);
  b.Name := FileName;
  b.Force := True;
  SaveReturnAddress;
  Bind (t, b);
  RestoreReturnAddress
end;

procedure Internal_AssignFile (tt: GPC_FDR; const FileName: String);
var t: Text absolute tt;
begin
  AssignFile (t, FileName)
end;

procedure Internal_Assign (tt: GPC_FDR; FileName: CString; NameLength: Integer);
var
  b: BindingType;
  t: Text absolute tt;
begin
  Unbind (t);
  b := Binding (t);
  if NameLength = 0 then
    b.Name := ''
  else
    b.Name := PChars0 (FileName)^[0 .. NameLength - 1];
  Bind (t, b)
end;

procedure Internal_Rename (aFile: GPC_FDR; const NewName: String);
begin
  FileMove (aFile, NewName, False)
end;

procedure Internal_ChDir (const Path: String);
begin
  if (InOutRes = 0) and (CStringChDir (Path) <> 0) then
    IOErrorCString (483, Path, True);  { cannot change to directory `%s' }
end;

procedure Internal_MkDir (const Path: String);
begin
  if (InOutRes = 0) and (CStringMkDir (Path) <> 0) then
    IOErrorCString (484, Path, True);  { cannot make directory `%s' }
end;

procedure Internal_RmDir (const Path: String);
begin
  if (InOutRes = 0) and (CStringRmDir (Path) <> 0) then
    IOErrorCString (485, Path, True);  { cannot remove directory `%s' }
end;

procedure Internal_Reset (f: GPC_FDR; const aFileName: String; FileNameGiven: Boolean; BufferSize: Integer);
begin
  SaveReturnAddress;
  if FileNameGiven then
    InternalOpen (f, aFileName, Length (aFileName), BufferSize, fo_Reset)
  else
    InternalOpen (f, nil, 0, BufferSize, fo_Reset);
  RestoreReturnAddress
end;

procedure Internal_Rewrite (f: GPC_FDR; const aFileName: String; FileNameGiven: Boolean; BufferSize: Integer);
begin
  SaveReturnAddress;
  if FileNameGiven then
    InternalOpen (f, aFileName, Length (aFileName), BufferSize, fo_Rewrite)
  else
    InternalOpen (f, nil, 0, BufferSize, fo_Rewrite);
  RestoreReturnAddress
end;

procedure Internal_Extend (f: GPC_FDR; const aFileName: String; FileNameGiven: Boolean; BufferSize: Integer);
begin
  SaveReturnAddress;
  if FileNameGiven then
    InternalOpen (f, aFileName, Length (aFileName), BufferSize, fo_Append)
  else
    InternalOpen (f, nil, 0, BufferSize, fo_Append);
  RestoreReturnAddress
end;

procedure AssignBinary (var t: Text; const FileName: String);
var b: BindingType;
begin
  Unbind (t);
  b := Binding (t);
  b.Name := FileName;
  b.Force := True;
  b.TextBinary := True;
  SaveReturnAddress;
  Bind (t, b);
  RestoreReturnAddress
end;

procedure AssignHandle (var t: AnyFile; Handle: Integer; CloseFlag: Boolean);
var b: BindingType;
begin
  Unbind (t);
  b := Binding (t);
  b.Handle := Handle;
  b.CloseFlag := CloseFlag;
  SaveReturnAddress;
  Bind (t, b);
  RestoreReturnAddress
end;

function Internal_SeekEOF (ff: GPC_FDR): Boolean;
var f: Text absolute ff;
begin
  repeat
    if EOF (f) then
      Return True
    else if EOLn (f) then
      ReadLn (f)
    else if f^ > ' ' then
      Return False
    else
      Get (f)
  until False
end;

function Internal_SeekEOLn (ff: GPC_FDR): Boolean;
var f: Text absolute ff;
begin
  repeat
    if EOF (f) or EOLn (f) then
      Return True
    else if f^ > ' ' then
      Return False
    else
      Get (f)
  until False
end;

function IOSelect (var Events: array [m .. n: Natural] of IOSelectType; MicroSeconds: MicroSecondTimeType): Integer;
type PFDRRecord = ^FDRRecord;
var
  SResult, Result, i, fn: Integer;
  WantRead, WantWrite, WantExcept, Buffered, Always, fa, fl: Boolean;
  fi: GPC_FDR;
  SelectEvents: array [m .. Max (m, n)] of InternalSelectType;

  function SelectOccurredRead: Boolean; attribute (inline);
  begin
    with Events[i] do
      begin
        Include (Occurred, SelectReadOrEOF);
        SelectOccurredRead := SelectReadOrEOF in Wanted;
        if (SelectRead in Wanted) or (SelectEOF in Wanted) then
          if GPC_EOF (PFDRRecord (f)^.f) then
            begin
              Include (Occurred, SelectEOF);
              if SelectEOF in Wanted then SelectOccurredRead := True
            end
          else
            begin
              Include (Occurred, SelectRead);
              if SelectRead in Wanted then SelectOccurredRead := True
            end
      end
  end;

begin
  SaveReturnAddress;
  Result := 0;
  Always := False;
  if (@Events = nil) or (m > n) then
    begin
      RestoreReturnAddress;
      Return 0 - Ord (SelectHandle (0, Null, MicroSeconds) < 0)
    end;
  for i := m to n do
    with Events[i] do
      begin
        Occurred := [];
        if f <> nil then fi := PFDRRecord (f)^.f else fi := nil;
        fl := False;
        fa := False;
        SelectEvents[i].Handle := -1;
        if (fi <> nil) and IsOpen (fi) then
          begin
            if fi^.SelectFunc <> nil then fn := fi^.SelectFunc (fi^.PrivateData^, SelectWrite in Wanted) else fn := fi^.Handle;
            WantRead := ((SelectReadOrEOF in Wanted) or (SelectRead in Wanted) or (SelectEOF in Wanted)) and fi^.Status.Reading;
            WantWrite := (SelectWrite in Wanted) and fi^.Status.Writing;
            WantExcept := SelectException in Wanted;
            Buffered := WantRead and (fi^.Status.EOF or not fi^.Status.LGet or (fi^.BufPos < fi^.BufSize));
            if Buffered and SelectOccurredRead then
              begin
                WantRead := False;
                fl := True
              end;
            if fn >= 0 then
              begin
                SelectEvents[i].Handle := fn;
                SelectEvents[i].Read := WantRead and not Buffered;
                SelectEvents[i].Write := WantWrite;
                SelectEvents[i].Exception := WantExcept;
                if SelectEvents[i].Read or SelectEvents[i].Write or SelectEvents[i].Exception then fa := True
              end;
            if (WantRead or WantWrite or WantExcept) and ((fi^.SelectProc <> nil) or (fn < 0)) then
              begin
                if fi^.SelectProc <> nil then
                  fi^.SelectProc (fi^.PrivateData^, WantRead, WantWrite, WantExcept)
                else
                  begin
                    if fi^.ReadFunc = nil then WantRead := False;
                    if fi^.WriteFunc = nil then WantWrite := False
                  end;
                if WantRead and SelectOccurredRead then fl := True;
                if WantWrite then
                  begin
                    Include (Occurred, SelectWrite);
                    fl := True
                  end;
                if WantExcept then
                  begin
                    Include (Occurred, SelectException);
                    fl := True
                  end
              end
          end;
        if (SelectAlways in Wanted) and fa then Always := True;
        if fl then Result := i
      end;
  if (Result <> 0) and not Always then
    begin
      RestoreReturnAddress;
      Return Result
    end;
  SResult := SelectHandle (n - m + 1, SelectEvents[m], MicroSeconds);
  for i := m to n do
    with Events[i] do
      begin
        if f <> nil then fi := PFDRRecord (f)^.f else fi := nil;
        if (fi <> nil) and IsOpen (fi) then
          begin
            WantRead := ((SelectReadOrEOF in Wanted) or (SelectRead in Wanted) or (SelectEOF in Wanted)) and fi^.Status.Reading;
            WantWrite := (SelectWrite in Wanted) and fi^.Status.Writing;
            WantExcept := SelectException in Wanted;
            fl := False;
            if (SResult > 0) and (SelectEvents[i].Handle >= 0) then
              begin
                if SelectEvents[i].Read then
                  begin
                    WantRead := False;
                    fl := SelectOccurredRead
                  end;
                if SelectEvents[i].Write then
                  begin
                    WantWrite := False;
                    Include (Occurred, SelectWrite);
                    fl := True
                  end;
                if SelectEvents[i].Exception then
                  begin
                    WantExcept := False;
                    Include (Occurred, SelectException);
                    fl := True
                  end
              end;
            { Call SelectProc even if select returned an error --
              TFDDs might use signals to interrupt select when ready. }
            if (WantRead or WantWrite or WantExcept) and (fi^.SelectProc <> nil) then
              begin
                fi^.SelectProc (fi^.PrivateData^, WantRead, WantWrite, WantExcept);
                if WantRead and SelectOccurredRead then fl := True;
                if WantWrite then
                  begin
                    Include (Occurred, SelectWrite);
                    fl := True
                  end;
                if WantExcept then
                  begin
                    Include (Occurred, SelectException);
                    fl := True
                  end
              end;
            if fl then Result := i
          end
      end;
  if (Result = 0) and (SResult < 0) then Result := -1;
  IOSelect := Result;
  RestoreReturnAddress
end;

function IOSelectRead (const Files: array [m .. n: Natural] of PAnyFile; MicroSeconds: MicroSecondTimeType): Integer;
var i: Integer;
begin
  SaveReturnAddress;
  if (@Files = nil) or (m > n) then
    IOSelectRead := 0 - Ord (SelectHandle (0, Null, MicroSeconds) < 0)
  else
    begin
      var Events: array [m .. n] of IOSelectType;
      for i := m to n do
        with Events[i] do
          begin
            Wanted := [SelectReadOrEOF];
            f := Files[i]
          end;
      IOSelectRead := IOSelect (Events, MicroSeconds)
    end;
  RestoreReturnAddress
end;

function StringTFDD_Read (var PrivateData; var Buffer; Size: SizeType) = Result: SizeType;
begin
  with ConstAnyString (PrivateData) do
    begin
      Result := Min (Size, Length);
      Move (Chars^, Buffer, Result);
      Chars := PChars (@Chars^[Result + 1]);
      Dec (Length, Result)
    end
end;

procedure AnyStringTFDD_Reset (var f: GPC_FDR; var Buf: ConstAnyString);
begin
  AssignTFDD (f, nil, nil, nil, StringTFDD_Read, nil, nil, nil, nil, @Buf);
  Internal_Reset (f, '', False, 1)
end;

procedure StringTFDD_Reset (var f: GPC_FDR; var Buf: ConstAnyString; var s: array [m .. n: Integer] of Char);
begin
  Buf.Length := n - m + 1;
  Buf.Chars := PChars (@s[m]);
  AnyStringTFDD_Reset (f, Buf)
end;

{$if False}  { @@ not used yet }
function StringTFDD_Write (var PrivateData; const Buffer; Size: SizeType) = Result: SizeType;
var CurLength: Cardinal;
begin
  with VarAnyString (PrivateData) do
    begin
      CurLength := VarAnyStringLength (VarAnyString (PrivateData));
      Result := Max (0, VarAnyStringSetLength (VarAnyString (PrivateData),
        Min (Capacity, CurLength + Size)) - CurLength);
      Move (Buffer, Chars^[CurLength + 1], Result);
      if Truncate then Result := Size
    end
end;

procedure AnyStringTFDD_Rewrite (var f: GPC_FDR; var Buf: VarAnyString);
begin
  Discard (VarAnyStringSetLength (Buf, 0));
  AssignTFDD (f, nil, nil, nil, nil, StringTFDD_Write, nil, nil, nil, @Buf);
  Internal_Rewrite (f, '', False, 1)
end;

procedure StringTFDD_Rewrite (var f: GPC_FDR; var Buf: VarAnyString; var s: String);
begin
  Buf.Capacity := s.Capacity;
  {$local R-} Buf.Chars := PChars (@s[1]); {$endlocal}
  Buf.Truncate := True;  { @@ }
  Buf.StringType := AnyStringLong;
  Buf.PLongLength := @Cardinal (GPC_PString (@s)^.Length);
  AnyStringTFDD_Rewrite (f, Buf)
end;
{$endif}

function IsTerminal (protected var f: GPC_FDR): Boolean;
begin
  IsTerminal := GetTerminalNameHandle (FileHandle (f), False, TtyDeviceName) <> nil
end;

function GetTerminalName (protected var f: GPC_FDR): TString;
begin
  GetTerminalName := CString2String (GetTerminalNameHandle (FileHandle (f), True, TtyDeviceName))
end;

end.
