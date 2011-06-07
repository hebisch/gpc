{ GPC demo program for the locale features of the
  internationalization unit.

  Copyright (C) 2001-2006 Free Software Foundation, Inc.

  Author: Eike Lange <eike.lange@uni-essen.de>

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License as
  published by the Free Software Foundation, version 2.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING. If not, write to
  the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
  Boston, MA 02111-1307, USA.

  As a special exception, if you incorporate even large parts of the
  code of this demo program into another program with substantially
  different functionality, this does not cause the other program to
  be covered by the GNU General Public License. This exception does
  not however invalidate any other reasons why it might be covered
  by the GNU General Public License. }

program LocaleDemo;

uses Intl;

var
  PLC : PLConv;

begin
  WriteLn (
'This demo prints out the settings of your locale.
For a German locale, the output should be as follows:

Current Locale Setting for `LC_MESSAGES'': de_DE

Some information about current locale:

Decimal Point: ,
Thousands Separator: .
Grouping:

Monetary:
Int. Currency Symbol: EUR
Local Currency Symbol: (Euro-Symbol)
Monetary Thousands Separator: .
Monetary Grouping:
Pos. Sign:
Neg. Sign: -
Int. Frac. Digits: 2
Frac. Digits: 2
Prec. Pos. Value: 0
Space separates curr. symbol: 1
Precedes Neg. Value: 0
Space separates curr. symbol from neg. value: 1
Sign Pos: 1
Neg Sign Pos: 1

Starting:');
  PLC := LocaleConv;
  WriteLn ('Current Locale Setting for `LC_MESSAGES'': ',
           SetLocale (LC_MESSAGES, ''));
  WriteLn;
  WriteLn ('Some information about current locale:');
  WriteLn;
  WriteLn ('Decimal Point: ', PLC^.DecimalPoint);
  WriteLn ('Thousands Separator: ', PLC^.ThousandsSep);
  WriteLn ('Grouping: ', PLC^.Grouping);
  WriteLn;
  WriteLn ('Monetary:');
  WriteLn ('Int. Currency Symbol: ', PLC^.IntCurrSymbol);
  WriteLn ('Local Currency Symbol: ', PLC^.CurrencySymbol);
  WriteLn ('Monetary Thousands Separator: ', PLC^.MonThousandsSep);
  WriteLn ('Monetary Grouping: ', PLC^.MonGrouping);
  WriteLn ('Pos. Sign: ', PLC^.PositiveSign);
  WriteLn ('Neg. Sign: ', PLC^.NegativeSign);
  WriteLn ('Int. Frac. Digits: ', PLC^.IntFracDigits);
  WriteLn ('Frac. Digits: ', PLC^.FracDigits);
  WriteLn ('Prec. Pos. Value: ', PLC^.PCSPrecedes);
  WriteLn ('Space separates curr. symbol: ', PLC^.PSepBySpace);
  WriteLn ('Precedes Neg. Value: ', PLC^.NCSPrecedes);
  WriteLn ('Space separates curr. symbol from neg. value: ', PLC^.NSepBySpace);
  WriteLn ('Sign Pos: ', PLC^.PSignPosn);
  WriteLn ('Neg Sign Pos: ', PLC^.NSignPosn);
  Dispose (PLC)
end.
