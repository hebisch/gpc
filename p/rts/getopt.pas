{ Command line option parsing

  Copyright (C) 1987-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

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

unit GetOpt; attribute (name = '_p__rts_GetOpt');

interface

uses String1, String2;

const
  EndOfOptions      = #255;
  NoOption          = #1;
  UnknownOption     = '?';
  LongOption        = #0;
  UnknownLongOption = '?';

var
  FirstNonOption        : Integer = 0; attribute (name = '_p_FirstNonOption');
  HasOptionArgument     : Boolean = False; attribute (name = '_p_HasOptionArgument');
  OptionArgument        : TString; attribute (name = '_p_OptionArgument');
  UnknownOptionCharacter: Char    = '?'; attribute (name = '_p_UnknownOptionCharacter');
  GetOptErrorFlag       : Boolean = True; attribute (name = '_p_GetOptErrorFlag');

{ Parses command line arguments for options and returns the next
  one.

  If a command line argument starts with `-', and is not exactly `-'
  or `--', then it is an option element. The characters of this
  element (aside from the initial `-') are option characters. If
  `GetOpt' is called repeatedly, it returns successively each of the
  option characters from each of the option elements.

  If `GetOpt' finds another option character, it returns that
  character, updating `FirstNonOption' and internal variables so
  that the next call to `GetOpt' can resume the scan with the
  following option character or command line argument.

  If there are no more option characters, `GetOpt' returns
  EndOfOptions. Then `FirstNonOption' is the index of the first
  command line argument that is not an option. (The command line
  arguments have been permuted so that those that are not options
  now come last.)

  OptString must be of the form `[+|-]abcd:e:f:g::h::i::'.

  a, b, c are options without arguments
  d, e, f are options with required arguments
  g, h, i are options with optional arguments

  Arguments are text following the option character in the same
  command line argument, or the text of the following command line
  argument. They are returned in OptionArgument. If an option has no
  argument, OptionArgument is empty. The variable HasOptionArgument
  tells whether an option has an argument. This is mostly useful for
  options with optional arguments, if one wants to distinguish an
  empty argument from no argument.

  If the first character of OptString is `+', GetOpt stops at the
  first non-option argument.

  If it is `-', GetOpt treats non-option arguments as options and
  return NoOption for them.

  Otherwise, GetOpt permutes arguments and handles all options,
  leaving all non-options at the end. However, if the environment
  variable POSIXLY_CORRECT is set, the default behaviour is to stop
  at the first non-option argument, as with `+'.

  The special argument `--' forces an end of option-scanning
  regardless of the first character of OptString. In the case of
  `-', only `--' can cause GetOpt to return EndOfOptions with
  FirstNonOption <= ParamCount.

  If an option character is seen that is not listed in OptString,
  UnknownOption is returned. The unrecognized option character is
  stored in UnknownOptionCharacter. Unless GetOptErrorFlag is set to
  False, an error message is printed to StdErr automatically. }
function  GetOpt (const OptString: String): Char; attribute (name = '_p_GetOpt');

type
  OptArgType = (NoArgument, RequiredArgument, OptionalArgument);

  OptionType = record
    OptionName: CString;
    Argument  : OptArgType;
    Flag      : ^Char;  { if nil, v is returned. Otherwise, Flag^ is ... }
    v         : Char    { ... set to v, and LongOption is returned }
  end;

{ Recognize short options, described by OptString as above, and long
  options, described by LongOptions.

  Long-named options begin with `--' instead of `-'. Their names may
  be abbreviated as long as the abbreviation is unique or is an
  exact match for some defined option. If they have an argument, it
  follows the option name in the same argument, separated from the
  option name by a `=', or else the in next argument. When GetOpt
  finds a long-named option, it returns LongOption if that option's
  `Flag' field is non-nil, and the value of the option's `v' field
  if the `Flag' field is nil.

  LongIndex, if not Null, returns the index in LongOptions of the
  long-named option found. It is only valid when a long-named option
  has been found by the most recent call.

  If LongOnly is set, `-' as well as `--' can indicate a long
  option. If an option that starts with `-' (not `--') doesn't match
  a long option, but does match a short option, it is parsed as a
  short option instead. If an argument has the form `-f', where f is
  a valid short option, don't consider it an abbreviated form of a
  long option that starts with `f'. Otherwise there would be no way
  to give the `-f' short option. On the other hand, if there's a
  long option `fubar' and the argument is `-fu', do consider that an
  abbreviation of the long option, just like `--fu', and not `-f'
  with argument `u'. This distinction seems to be the most useful
  approach.

  As an additional feature (not present in the C counterpart), if
  the last character of OptString is `-' (after a possible starting
  `+' or `-' character), or OptString is empty, all long options
  with a nil `Flag' field will automatically be recognized as short
  options with the character given by the `v' field. This means, in
  the common (and recommended) case that all short options have long
  equivalents, you can simply pass an empty OptString (or pass `+-'
  or `--' as OptString if you want this behaviour, see the comment
  for GetOpt), and you will only have to maintain the LongOptions
  array when you add or change options. }
function  GetOptLong (const OptString: String; const LongOptions: array [m .. n: Integer] of OptionType { can be Null };
                      var LongIndex: Integer { can be Null }; LongOnly: Boolean): Char; attribute (name = '_p_GetOptLong');

{ Reset GetOpt's state and make the next GetOpt or GetOptLong start
  (again) with the StartArgument'th argument (may be 1). This is
  useful for special purposes only. It is *necessary* to do this
  after altering the contents of CParamCount/CParameters (which is
  not usually done, either). }
procedure ResetGetOpt (StartArgument: Integer); attribute (name = '_p_ResetGetOpt');

implementation

{$pointer-arithmetic,cstrings-as-strings}

var
  ArgumentToStart: Integer = 1; attribute (name = '_p_ArgumentToStart');

function GetOpt (const OptString: String): Char;
begin
  GetOpt := GetOptLong (OptString, Null, Null, False)
end;

function GetOptLong (const OptString: String; const LongOptions: array [m .. n: Integer] of OptionType { can be Null };
                     var LongIndex: Integer { can be Null }; LongOnly: Boolean): Char;
var
  { The next char to be scanned in the option-element
     in which the last option character we returned was found.
     This allows us to pick up the scan where we left off.
     If this is nil, or an empty string, it means resume the scan
     by advancing to the next argument. }
  NextChar: CString; attribute (static);

  { Describe how to deal with options that follow non-option arguments.
    Permute is the default, RequireOrder corresponds to `+',
    ReturnInOrder to `-'. }
  Ordering: (RequireOrder, Permute, ReturnInOrder); attribute (static);

  { Handle permutation of arguments.
    Describe the part of CParameters that contains non-options that have
    been skipped. FirstNonOpt is the index in CParameters of the first
    of them; LastNonOpt is the index after the last of them. }
  FirstNonOpt, LastNonOpt: Integer; attribute (static);

  NameEnd: CString;
  Found: (f_None, f_Exact, f_NonExact, f_Ambiguous);
  IndFound, OptStringStart, OptStringIndex, i: Integer;
  c: Char;
  OptArgument: OptArgType;
  ShortOptionsFromLongOptions: Boolean;

  { Exchange two adjacent subsequences of CParameters.
    One subsequence is elements [FirstNonOpt, LastNonOpt)
    which contains all the non-options that have been skipped so far.
    The other is elements [LastNonOpt, FirstNonOption), which contains
    all the options processed since those non-options were skipped.
    `FirstNonOpt' and `LastNonOpt' are relocated so that they describe
    the new indices of the non-options in CParameters after they are moved. }
  procedure Exchange;
  var
    Bottom, Middle, Top, Len, i: Integer;
    Temp: CString;
  begin
    Bottom := FirstNonOpt;
    Middle := LastNonOpt;
    Top := FirstNonOption;
    { Exchange the shorter segment with the far end of the longer segment.
      That puts the shorter segment into the right place.
      It leaves the longer segment in the right place overall,
      but it consists of two parts that need to be swapped next. }
    while (Top > Middle) and (Middle > Bottom) do
      begin
        if Top - Middle > Middle - Bottom then
          begin
            { Bottom segment is the short one. }
            Len := Middle - Bottom;
            { Swap it with the top part of the top segment. }
            for i := 0 to Len - 1 do
              begin
                Temp := CParameters^[Bottom + i];
                CParameters^[Bottom + i] := CParameters^[Top - Len + i];
                CParameters^[Top - Len + i] := Temp
              end;
            { Exclude the moved bottom segment from further swapping. }
            Dec (Top, Len)
          end
        else
          begin
            { Top segment is the short one. }
            Len := Top - Middle;
            { Swap it with the bottom part of the bottom segment. }
            for i := 0 to Len - 1 do
              begin
                Temp := CParameters^[Bottom + i];
                CParameters^[Bottom + i] := CParameters^[Middle + i];
                CParameters^[Middle + i] := Temp
              end;
            { Exclude the moved top segment from further swapping. }
            Inc (Bottom, Len)
          end
      end;
    { Update records for the slots the non-options now occupy. }
    Inc (FirstNonOpt, FirstNonOption - LastNonOpt);
    LastNonOpt := FirstNonOption
  end;

  function IsShortOption (c: Char): Boolean;
  var i: Integer;
  begin
    IsShortOption := True;
    if PosFrom (c, OptString, OptStringStart) <> 0 then Exit;
    if ShortOptionsFromLongOptions then
      for i := m to n do
        with LongOptions[i] do
          if (Flag = nil) and (v = c) then Exit;
    IsShortOption := False
  end;

begin
  OptionArgument := '';
  HasOptionArgument := False;
  if FirstNonOption = 0 then
    begin
      { Start processing options with the first argument. }
      FirstNonOpt := ArgumentToStart;
      LastNonOpt := FirstNonOpt;
      FirstNonOption := FirstNonOpt;
      NextChar := nil;
      if (OptString <> '') and (OptString[1] = '-') then
        Ordering := ReturnInOrder
      else if (OptString <> '') and (OptString[1] = '+') then
        Ordering := RequireOrder
      else if CStringGetEnv ('POSIXLY_CORRECT') <> nil then
        Ordering := RequireOrder
      else
        Ordering := Permute
    end;
  if CParamCount = 0 then Return EndOfOptions;
  OptStringStart := 1;
  if (OptString <> '') and (OptString[1] in ['-', '+']) then Inc (OptStringStart);
  ShortOptionsFromLongOptions := (@LongOptions <> nil) and
    ((OptString = '') or ((Length (OptString) >= OptStringStart) and (OptString[Length (OptString)] = '-')));
  if (NextChar = nil) or (NextChar^ = #0) then
    begin
      { Advance to the next argument }
      if Ordering = Permute then
        begin
          { If we have just processed some options following some
            non-options, exchange them so that the options come first. }
          if (FirstNonOpt <> LastNonOpt) and (LastNonOpt <> FirstNonOption) then Exchange;
          if FirstNonOpt = LastNonOpt then FirstNonOpt := FirstNonOption;
          { Skip any additional non-options and extend the range of
            non-options previously skipped. }
          while (FirstNonOption < CParamCount) and ((CParameters^[FirstNonOption][0] <> '-') or
            (CParameters^[FirstNonOption][1] = #0)) do Inc (FirstNonOption);
          LastNonOpt := FirstNonOption
        end;
      { The special argument `--' means premature end of options. Skip it
        like a Null option, then exchange with previous non-options as if
        it were an option, then skip everything else like a non-option. }
      if (FirstNonOption <> CParamCount) and (CStringComp (CParameters^[FirstNonOption], '--') = 0) then
        begin
          Inc (FirstNonOption);
          if (FirstNonOpt <> LastNonOpt) and (LastNonOpt <> FirstNonOption) then Exchange;
          if FirstNonOpt = LastNonOpt then FirstNonOpt := FirstNonOption;
          LastNonOpt := CParamCount;
          FirstNonOption := CParamCount
        end;
      { If we have done all the arguments, stop the scan and back over any
        non-options that we skipped and permuted. }
      if FirstNonOption = CParamCount then
        begin
          { Set the next-argument-index to point at the non-options that
            we previously skipped, so the caller will digest them. }
          if FirstNonOpt <> LastNonOpt then FirstNonOption := FirstNonOpt;
          Return EndOfOptions
        end;
      { If we have come to a non-option and did not permute it, either stop
        the scan or describe it to the caller and pass it by. }
      if (CParameters^[FirstNonOption][0] <> '-') or (CParameters^[FirstNonOption][1] = #0) then
        begin
          if Ordering = RequireOrder then Return EndOfOptions;
          OptionArgument := CString2String (CParameters^[FirstNonOption]);
          HasOptionArgument := True;
          Inc (FirstNonOption);
          Return NoOption
        end;
      { We have found another option argument. Skip the initial punctuation. }
      NextChar := CParameters^[FirstNonOption] + 1 + Ord ((@LongOptions <> nil) and (CParameters^[FirstNonOption][1] = '-'))
    end;
  { Decode the current option argument.
    Check whether the argument is a long option. }
  if (@LongOptions <> nil) and ((CParameters^[FirstNonOption][1] = '-') or
      (LongOnly and ((CParameters^[FirstNonOption][2] <> #0) or
        not IsShortOption (CParameters^[FirstNonOption][1])))) then
    begin
      { Test all long options for either exact match or abbreviated matches. }
      NameEnd := NextChar;
      while (NameEnd^ <> #0) and (NameEnd^ <> '=') do Inc (NameEnd);
      IndFound := 0;
      Found := f_None;
      for i := m to n do
        if CStringLComp (LongOptions[i].OptionName, NextChar, NameEnd - NextChar) = 0 then
          if CStringLength (LongOptions[i].OptionName) = NameEnd - NextChar then
            begin
              { Exact match found. }
              IndFound := i;
              Found := f_Exact;
              Break
            end
          else if Found = f_None then
            begin
              { First nonexact match found. }
              IndFound := i;
              Found := f_NonExact
            end
          else
            Found := f_Ambiguous;  { Second or later nonexact match found. }
      if Found <> f_None then
        with LongOptions[IndFound] do
          begin
            NextChar := nil;
            Inc (FirstNonOption);
            if Found = f_Ambiguous then
              begin
                if GetOptErrorFlag then WriteLn (StdErr, CParameters^[0], ': option `', CParameters^[FirstNonOption - 1], ''' is ambiguous');
                UnknownOptionCharacter := UnknownLongOption;
                Return UnknownOption
              end;
            if NameEnd^ <> #0 then
              begin
                if Argument <> NoArgument then
                  begin
                    OptionArgument := CString2String (NameEnd + 1);
                    HasOptionArgument := True
                  end
                else
                  begin
                    if GetOptErrorFlag then
                      if CParameters^[FirstNonOption - 1][1] = '-' then
                        WriteLn (StdErr, CParameters^[0], ': option `--',
                                 OptionName, ''' doesn''t allow an argument')
                      else
                        WriteLn (StdErr, CParameters^[0], ': option `',
                                 CParameters^[FirstNonOption - 1][0],
                                 OptionName, ''' doesn''t allow an argument');
                    UnknownOptionCharacter := v;
                    Return UnknownOption
                  end
              end
            else if Argument = RequiredArgument then
              if FirstNonOption < CParamCount then
                begin
                  OptionArgument := CString2String (CParameters^[FirstNonOption]);
                  HasOptionArgument := True;
                  Inc (FirstNonOption)
                end
              else
                begin
                  if GetOptErrorFlag then WriteLn (StdErr, CParameters^[0], ': option `', CParameters^[FirstNonOption - 1], ''' requires an argument');
                  UnknownOptionCharacter := v;
                  if (OptString <> '') and (OptString[OptStringStart] = ':') then
                    Return ':'
                  else
                    Return UnknownOption
                end;
            if @LongIndex <> nil then LongIndex := IndFound;
            if Flag <> nil then
              begin
                Flag^ := v;
                Return LongOption
              end;
            Return v
          end;
      { Can't find it as a long option. If LongOnly is not set, or the
        option starts with `--' or is not a valid short option, then it's
        an error. Otherwise interpret it as a short option. }
      if not LongOnly or (CParameters^[FirstNonOption][1] = '-') or not IsShortOption (NextChar^) then
        begin
          if GetOptErrorFlag then
            if CParameters^[FirstNonOption][1] = '-' then
              WriteLn (StdErr, CParameters^[0], ': unrecognized option `--', NextChar, '''')
            else
              WriteLn (StdErr, CParameters^[0], ': unrecognized option `',
                       CParameters^[FirstNonOption][0], NextChar, '''');
          NextChar := nil;
          Inc (FirstNonOption);
          UnknownOptionCharacter := UnknownLongOption;
          Return UnknownOption
        end
    end;
  { Look at and handle the next short option-character. }
  c := NextChar^;
  Inc (NextChar);
  { Increment FirstNonOption when we start to process its last character. }
  if NextChar^ = #0 then Inc (FirstNonOption);
  OptArgument := NoArgument;
  if c = ':' then
    OptStringIndex := 0
  else
    begin
      OptStringIndex := PosFrom (c, OptString, OptStringStart);
      if OptStringIndex <> 0 then
        if (OptStringIndex + 1 > Length (OptString)) or (OptString[OptStringIndex + 1] <> ':') then
          OptArgument := NoArgument
        else if (OptStringIndex + 2 > Length (OptString)) or (OptString[OptStringIndex + 2] <> ':') then
          OptArgument := RequiredArgument
        else
          OptArgument := OptionalArgument
      else if ShortOptionsFromLongOptions then
        for i := m to n do
          with LongOptions[i] do
            if (Flag = nil) and (v = c) then
              begin
                OptStringIndex := 1;  { The value is irrelevant as long as it's <> 0 }
                OptArgument := Argument;
                Break
              end
    end;
  if OptStringIndex = 0 then
    begin
      if GetOptErrorFlag then WriteLn (StdErr, CParameters^[0], ': invalid option -- ', c);
      UnknownOptionCharacter := c;
      Return UnknownOption
    end;
  case OptArgument of
    OptionalArgument: begin
                        if NextChar^ <> #0 then
                          begin
                            OptionArgument := CString2String (NextChar);
                            HasOptionArgument := True;
                            Inc (FirstNonOption)
                          end
                        else
                          begin
                            OptionArgument := '';
                            HasOptionArgument := False
                          end;
                        NextChar := nil
                      end;
    RequiredArgument: begin
                        if NextChar^ <> #0 then
                          begin
                            OptionArgument := CString2String (NextChar);
                            HasOptionArgument := True;
                            Inc (FirstNonOption)
                          end
                        else if FirstNonOption = CParamCount then
                          begin
                            if GetOptErrorFlag then WriteLn (StdErr, CParameters^[0], ': option requires an argument -- ', c);
                            UnknownOptionCharacter := c;
                            if (OptString <> '') and (OptString[OptStringStart] = ':') then
                              c := ':'
                            else
                              c := UnknownOption
                          end
                        else
                          begin
                            { We already incremented `FirstNonOption' once; increment it again when taking next argument. }
                            OptionArgument := CString2String (CParameters^[FirstNonOption]);
                            HasOptionArgument := True;
                            Inc (FirstNonOption)
                          end;
                        NextChar := nil
                      end;
  end;
  GetOptLong := c
end;

procedure ResetGetOpt (StartArgument: Integer);
begin
  FirstNonOption         := 0;
  HasOptionArgument      := False;
  OptionArgument         := '';
  UnknownOptionCharacter := '?';
  ArgumentToStart        := StartArgument
end;

begin
  OptionArgument := ''
end.
