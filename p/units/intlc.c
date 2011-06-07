/*Support routines for intl.pas

  Copyright (C) 2001-2006 Free Software Foundation, Inc.

  Author: Eike Lange <eike.lange@uni-essen.de>

  This unit is free software; you can redistribute it and/or modify
  it under the terms of the GNU Library General Public License as
  published by the Free Software Foundation, version 3.

  This unit is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; see the file COPYING.LIB. If not,
  write to the Free Software Foundation, Inc., 59 Temple Place -
  Suite 330, Boston, MA 02111-1307, USA. */

#include <stdlib.h>
#include <locale.h>
#include <libintl.h>
#include <limits.h>

/* In a GNU environment, we know that
   LC_CTYPE=0, LC_NUMERIC=1, LC_TIME=2, LC_COLLATE=3,
   LC_MONETARY=4, LC_MESSAGES=5, LC_ALL=6. But we don't
   know, if this is right for each and every system we
   are running on. So make the values available to
   Pascal via variables. */
int _p_LC_CTYPE    = LC_CTYPE;
int _p_LC_NUMERIC  = LC_NUMERIC;
int _p_LC_TIME     = LC_TIME;
int _p_LC_COLLATE  = LC_COLLATE;
int _p_LC_MONETARY = LC_MONETARY;
int _p_LC_MESSAGES = LC_MESSAGES;
int _p_LC_ALL      = LC_ALL;

char _p_CHAR_MAX = CHAR_MAX;

/* Structure giving information about numeric and monetary notation.
   This is the original lconv structure and we copy any other
   similar (maybe different order) struct in it. */
typedef struct
{
  /* Numeric (non-monetary) information. */
  char *decimal_point, *thousands_sep, *grouping;
  /* Monetary information. */
  char *int_curr_symbol, *currency_symbol, *mon_decimal_point,
       *mon_thousands_sep, *mon_grouping, *positive_sign,
       *negative_sign,
       int_frac_digits, frac_digits, p_cs_precedes, p_sep_by_space,
       n_cs_precedes, n_sep_by_space, p_sign_posn, n_sign_posn;
} OrigLConv;

/* Locale */

char *_p_CSetLocale (int category, char *locale)
{
  return setlocale (category, locale);
}

OrigLConv *_p_CLocaleConv (void)
{
  struct lconv *lc;
  OrigLConv *plc = malloc (sizeof (OrigLConv));
  lc = localeconv ();
  plc->decimal_point     = lc->decimal_point;
  plc->thousands_sep     = lc->thousands_sep;
  plc->grouping          = lc->grouping;
  plc->int_curr_symbol   = lc->int_curr_symbol;
  plc->currency_symbol   = lc->currency_symbol;
  plc->mon_decimal_point = lc->mon_decimal_point;
  plc->mon_thousands_sep = lc->mon_thousands_sep;
  plc->mon_grouping      = lc->mon_grouping;
  plc->positive_sign     = lc->positive_sign;
  plc->negative_sign     = lc->negative_sign;
  plc->int_frac_digits   = lc->int_frac_digits;
  plc->frac_digits       = lc->frac_digits;
  plc->p_cs_precedes     = lc->p_cs_precedes;
  plc->p_sep_by_space    = lc->p_sep_by_space;
  plc->n_cs_precedes     = lc->n_cs_precedes;
  plc->n_sep_by_space    = lc->n_sep_by_space;
  plc->p_sign_posn       = lc->p_sign_posn;
  plc->n_sign_posn       = lc->n_sign_posn;
  return plc;
}

/* LibIntl */

char *_p_CGetText (char *msgid)
{
  return gettext (msgid);
}

char *_p_CDGetText (char *domainname, char *msgid)
{
  return dgettext (domainname, msgid);
}

char *_p_CDCGetText (char *domainname, char *msgid, int category)
{
  return dcgettext (domainname, msgid, category);
}

char *_p_CTextDomain (char *domainname)
{
  return textdomain (domainname);
}

char *_p_CBindTextDomain (char *domainname, char *dirname)
{
  return bindtextdomain (domainname, dirname);
}
