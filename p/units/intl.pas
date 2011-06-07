{ Welcome to the wonderful world of
  INTERNATIONALIZATION (i18n).

  This unit provides the powerful mechanism of national language
  support by accessing `.mo' files and locale information.

  It includes:
    locales (not xlocales) and libintl.

  See documentation for gettext (`info gettext') for details.

  Because GPC can deal with both CStrings and Pascal Strings, there
  is an interface for both types of arguments and function results
  with slightly different names.

  E.g. for Pascal strings:

    function GetText (const MsgId: String): TString;

  And the same as above, but with a C interface:

    function GetTextC (MsgId: CString): CString;

  `PLConv' in Pascal is very different from `struct lconv *' in C.
  Element names do not have underscores and have sometimes different
  sizes. The conversion is done automatically and has correct
  results.

  Furthermore, we have a tool similar to `xgettext' to extract all
  strings out of a Pascal source. It extracts the strings and writes
  a complete `.po' file to a file. See
  http://www.gnu-pascal.de/contrib/eike/
  The filename is pas2po-VERSION.tar.gz.

  Copyright (C) 2001-2006 Free Software Foundation, Inc.

  Author: Eike Lange <eike.lange@uni-essen.de>

  GNU Pascal is free software; you can redistribute it and/or modify
  it under the terms of the GNU Library General Public License as
  published by the Free Software Foundation, version 3.

  GNU Pascal is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; see the file COPYING.LIB. If not,
  write to the Free Software Foundation, Inc., 59 Temple Place -
  Suite 330, Boston, MA 02111-1307, USA. }

{$gnu-pascal,I-}
{$if __GPC_RELEASE__ < 20030303}
{$error This unit requires GPC release 20030303 or newer.}
{$endif}

unit Intl;

interface

uses GPC;

type
  IntlString = String (16);

  { Pascal translation from OrigLConv in intlc.c }
  PLConv = ^TLConv;
  TLConv = record
    { Numeric (non-monetary) information. }

    { Decimal point character. }
    DecimalPoint: IntlString;

    { Thousands separator. }
    ThousandsSep: IntlString;

    { Each element is the number of digits in each group;
      elements with higher indices are farther left.
      An element with value CharMax means that no further grouping
      is done.
      An element with value Chr (0) means that the previous element
      is used for all groups farther left. }
    Grouping: IntlString;

    { Monetary information. }

    { First three chars are a currency symbol from ISO 4217.
      Fourth char is the separator.  Fifth char is Chr (0). }
    IntCurrSymbol: IntlString;

    { Local currency symbol. }
    CurrencySymbol: IntlString;

    { Decimal point character. }
    MonDecimalPoint: IntlString;

    { Thousands separator. }
    MonThousandsSep: IntlString;

    { Like `Grouping' element (above). }
    MonGrouping: IntlString;

    { Sign for positive values. }
    PositiveSign: IntlString;

    { Sign for negative values. }
    NegativeSign: IntlString;

    { Int'l fractional digits. }
    IntFracDigits: ByteInt;

    { Local fractional digits. }
    FracDigits: ByteInt;

    { 1 if CurrencySymbol precedes a positive value, 0 if it
      succeeds. }
    PCSPrecedes: ByteInt;

    { 1 iff a space separates CurrencySymbol from a positive
      value. }
    PSepBySpace: ByteInt;

    { 1 if CurrencySymbol precedes a negative value, 0 if it
      succeeds. }
    NCSPrecedes: ByteInt;

    { 1 iff a space separates CurrencySymbol from a negative
      value. }
    NSepBySpace: ByteInt;

    { Positive and negative sign positions:
      0 Parentheses surround the quantity and CurrencySymbol.
      1 The sign string precedes the quantity and CurrencySymbol.
      2 The sign string follows the quantity and CurrencySymbol.
      3 The sign string immediately precedes the CurrencySymbol.
      4 The sign string immediately follows the CurrencySymbol. }
    PSignPosn,
    NSignPosn: ByteInt;
  end;

{ Please do not assign anything to these identifiers! }
var
  LC_CTYPE:    CInteger; external name '_p_LC_CTYPE';
  LC_NUMERIC:  CInteger; external name '_p_LC_NUMERIC';
  LC_TIME:     CInteger; external name '_p_LC_TIME';
  LC_COLLATE:  CInteger; external name '_p_LC_COLLATE';
  LC_MONETARY: CInteger; external name '_p_LC_MONETARY';
  LC_MESSAGES: CInteger; external name '_p_LC_MESSAGES';
  LC_ALL:      CInteger; external name '_p_LC_ALL';
  CharMax:     Char;     external name '_p_CHAR_MAX';

{@section Locales }

{ Set and/or return the current locale. }
function SetLocale (Category: Integer; const Locale: String): TString; attribute (ignorable);

{ Set and/or return the current locale. Same as above, but returns
  a CString. }
function SetLocaleC (Category: Integer; const Locale: String): CString; attribute (ignorable);

{ Return the numeric/monetary information for the current locale.
  The result is allocated from the heap. You can Dispose it when
  you don't need it anymore. }
function LocaleConv: PLConv;

{@section GetText }

{ Look up MsgId in the current default message catalog for the
  current LC_MESSAGES locale.  If not found, returns MsgId itself
  (the default text). }
function GetText (const MsgId: String): TString;

{ Same as above, but with a C interface }
function GetTextC (MsgId: CString): CString;

{ Look up MsgId in the DomainName message catalog for the current
  LC_MESSAGES locale. }
function DGetText (const DomainName, MsgId: String): TString;

{ Same as above, but with a C interface }
function DGetTextC (DomainName, MsgId: CString): CString;

{ Look up MsgId in the DomainName message catalog for the current
  Category locale. }
function DCGetText (const DomainName, MsgId: String; Category: Integer): TString;

{ Same as above, but with a C interface }
function DCGetTextC (DomainName, MsgId: CString; Category: Integer): CString;

{ Set the current default message catalog to DomainName.
  If DomainName is empty, reset to the default of `messages'. }
function TextDomain (const DomainName: String): TString; attribute (ignorable);

{ Same as above, but with a C interface.
  If DomainName is nil, return the current default. }
function TextDomainC (DomainName: CString): CString; attribute (ignorable);

{ Specify that the DomainName message catalog will be found
  in DirName rather than in the system locale data base. }
function BindTextDomain (const DomainName, DirName: String): TString; attribute (ignorable);

{ Same as above, but with a C interface }
function BindTextDomainC (DomainName, DirName: CString): CString; attribute (ignorable);

implementation

{$L intlc.c}

{$ifndef HAVE_NO_RTS_CONFIG_H}
{$include "rts-config.inc"}
{$endif}
{$ifdef HAVE_LIBINTL}
{$L intl}
{$endif}
{$if defined (__OS_DOS__) and defined (HAVE_LIBICONV)}
{$L iconv}
{$endif}

type
  { cf. intlc.c }
  POrigLConv = ^OrigLConv;
  OrigLConv = record
    DecimalPoint, ThousandsSep, Grouping, IntCurrSymbol,
      CurrencySymbol, MonDecimalPoint, MonThousandsSep,
      MonGrouping, PositiveSign, NegativeSign: CString;
    IntFracDigits, FracDigits, PCSPrecedes, PSepBySpace,
      NCSPrecedes, NSepBySpace, PSignPosn, NSignPosn: ByteInt
  end;

function CSetLocale (Category: CInteger; Locale: CString): CString; external name '_p_CSetLocale';
function CLocaleConv: POrigLConv; external name '_p_CLocaleConv';
function CGetText (MsgId: CString): CString; external name '_p_CGetText';
function CDGetText (DomainName, MsgId: CString): CString; external name '_p_CDGetText';
function CDCGetText (DomainName, MsgId: CString; Category: CInteger): CString; external name '_p_CDCGetText';
function CTextDomain (DomainName: CString): CString; external name '_p_CTextDomain';
function CBindTextDomain (DomainName, DirName: CString): CString; external name '_p_CBindTextDomain';

function SetLocale(Category: Integer; const Locale: String): TString;
begin
  SetLocale := CString2String (CSetLocale (Category, Locale))
end;

function SetLocaleC(Category: Integer; const Locale: String): CString;
begin
  SetLocaleC := CSetLocale (Category, Locale)
end;

function LocaleConv: PLConv;
var
  POLC: POrigLConv;
  PLC: PLConv;
begin
  POLC := CLocaleConv;
  New (PLC);
  PLC^.DecimalPoint := CString2String(POLC^.DecimalPoint);
  PLC^.ThousandsSep := CString2String(POLC^.ThousandsSep);
  PLC^.Grouping := CString2String(POLC^.Grouping);
  PLC^.IntCurrSymbol := CString2String(POLC^.IntCurrSymbol);
  PLC^.CurrencySymbol := CString2String(POLC^.CurrencySymbol);
  PLC^.MonDecimalPoint := CString2String(POLC^.MonDecimalPoint);
  PLC^.MonThousandsSep := CString2String(POLC^.MonThousandsSep);
  PLC^.MonGrouping := CString2String(POLC^.MonGrouping);
  PLC^.PositiveSign := CString2String(POLC^.PositiveSign);
  PLC^.NegativeSign := CString2String(POLC^.NegativeSign);
  PLC^.IntFracDigits := POLC^.IntFracDigits;
  PLC^.FracDigits := POLC^.FracDigits;
  PLC^.PCSPrecedes := POLC^.PCSPrecedes;
  PLC^.PSepBySpace := POLC^.PSepBySpace;
  PLC^.NCSPrecedes := POLC^.NCSPrecedes;
  PLC^.NSepBySpace := POLC^.NSepBySpace;
  PLC^.PSignPosn := POLC^.PSignPosn;
  PLC^.NSignPosn := POLC^.NSignPosn;
  Dispose (POLC);
  LocaleConv := PLC
end;

function GetText (const MsgId: String): TString;
begin
  GetText := CString2String (CGetText (MsgId))
end;

function GetTextC (MsgId: CString): CString;
begin
  GetTextC := CGetText (MsgId)
end;

function DGetText (const DomainName, MsgId: String): TString;
begin
  DGetText := CString2String (CDGetText (DomainName, MsgId))
end;

function DGetTextC (DomainName, MsgId: CString): CString;
begin
  DGetTextC := CDGetText (DomainName, MsgId)
end;

function DCGetText (const DomainName, MsgId: String; Category: Integer): TString;
begin
  DCGetText := CString2String (CDCGetText (DomainName, MsgId, Category))
end;

function DCGetTextC (DomainName, MsgId: CString; Category: Integer): CString;
begin
  DCGetTextC := CDCGetText (DomainName, MsgId, Category)
end;

function TextDomain (const DomainName: String): TString;
begin
  TextDomain := CString2String (CTextDomain (DomainName))
end;

function TextDomainC (DomainName: CString): CString;
begin
  TextDomainC := CTextDomain (DomainName)
end;

function BindTextDomain (const DomainName, DirName: String): TString;
begin
  BindTextDomain := CString2String (CBindTextDomain (DomainName, DirName))
end;

function BindTextDomainC (DomainName, DirName: CString): CString;
begin
  BindTextDomainC := CBindTextDomain (DomainName, DirName)
end;

end.
