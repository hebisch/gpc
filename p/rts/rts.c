/*C routines of the RTS. These are mostly small wrappers around libc
  routines. The main purpose of this file is to ensure portability.
  Higher level stuff is in other files.

  Copyright (C) 1985-2006 Free Software Foundation, Inc.

  Authors: Jukka Virtanen <jtv@hut.fi>
           J.J. van der Heijden <j.j.vanderheijden@student.utwente.nl>
           Peter Gerwinski <peter@gerwinski.de>
           Frank Heckenbach <frank@pascal.gnu.de>
           Nicola Girardi <nicola@g-n-u.de>

  1985-06-15: First version for Pax compiler at hut.fi.

  Later converted for GNU Pascal Compiler (GPC). The Run Time System
  should support all features of the Extended Pascal Standard.

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
  General Public License. */

#if defined (MSDOS) || defined (_WIN32) || defined (__EMX__)
#define __OS_DOS__
#endif

/* These should be consistent with configure.in */
#define _GNU_SOURCE
#define _LARGEFILE64_SOURCE
#define _FILE_OFFSET_BITS 64

/* Created by autoconf */
#ifndef HAVE_NO_RTS_CONFIG_H
#include "rts-config.h"
#endif

#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif

#ifdef STDC_HEADERS
#include <stdlib.h>
#include <string.h>
#endif

#ifdef HAVE_CTYPE_H
#include <ctype.h>
#endif

#if HAVE_DIRENT_H
#include <dirent.h>
#else
#define dirent direct
#if HAVE_SYS_NDIR_H
#include <sys/ndir.h>
#endif
#if HAVE_SYS_DIR_H
#include <sys/dir.h>
#endif
#if HAVE_NDIR_H
#include <ndir.h>
#endif
#endif

#ifdef HAVE_ERRNO_H
#include <errno.h>
#endif

#ifdef HAVE_FCNTL_H
#include <fcntl.h>
#endif

#ifdef HAVE_SYS_FILE_H
#include <sys/file.h>
#endif

#ifdef HAVE_FNMATCH_H
#include <fnmatch.h>
#endif

#ifdef HAVE_GLOB_H
#include <glob.h>
#endif

#ifdef HAVE_LIMITS_H
#include <limits.h>
#endif

#ifdef HAVE_LOCALE_H
#include <locale.h>
#endif

#ifdef HAVE_MATH_H
#include <math.h>
#endif

#if HAVE_SYS_MMAN_H
#include <sys/mman.h>
#endif

#ifdef HAVE_SYS_PARAM_H
#include <sys/param.h>
#endif

/* needed by e.g. mingw for getpid */
#ifdef HAVE_PROCESS_H
#include <process.h>
#endif

#ifdef HAVE_PWD_H
#include <pwd.h>
#endif

/* needed by e.g. FreeBSD and DJGPP for rename :-( */
#ifdef HAVE_STDIO_H
#include <stdio.h>
#endif

#ifdef HAVE_SIGNAL_H
#include <signal.h>
#elif defined (HAVE_BSD_SIGNAL_H)
#include <bsd/signal.h>
#endif

#ifdef HAVE_SYS_STAT_H
#include <sys/stat.h>
#endif

/* needed by e.g. Solaris to stat a file system */
#ifdef HAVE_SYS_STATVFS_H
#include <sys/statvfs.h>
#endif
/* needed by e.g. Linux and DJGPP to stat a file system */
#ifdef HAVE_SYS_VFS_H
#include <sys/vfs.h>
#endif
/* needed by e.g. FreeBSD to stat a file system */
#ifdef HAVE_SYS_MOUNT_H
#include <sys/mount.h>
#endif

#ifdef HAVE_TERMIO_H
#include <termio.h>
#endif

#ifdef HAVE_TERMIOS_H
#include <termios.h>
#endif

#if TIME_WITH_SYS_TIME
#include <sys/time.h>
#include <time.h>
#else
#if HAVE_SYS_TIME_H
#include <sys/time.h>
#else
#include <time.h>
#endif
#endif

#ifdef HAVE_SYS_RESOURCE_H
#include <sys/resource.h>
#endif

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

/* needed by e.g. IRIX and AIX for select and the macros like FD_SET */
#ifdef HAVE_SYS_SELECT_H
#include <sys/select.h>
#endif
/* Workaround for a bug in e.g. Linux libc 5.4.46 */
#undef FD_ZERO
#define FD_ZERO(p) (memset ((char *) (p), 0, sizeof (*(p))))

#ifdef HAVE_UTIME_H
#include <utime.h>
#elif defined(HAVE_SYS_UTIME_H)
#include <sys/utime.h>
#endif

#if HAVE_SYS_UTSNAME_H
#include <sys/utsname.h>
#endif

#if HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif

/* os-hacks.h can be added on any system to remove incompatibilities etc.
   This should be the last include. */
#ifdef HAVE_OS_HACKS_H
#include <os-hacks.h>
#endif

#ifndef HAVE_SSIZE_T
typedef signed long int ssize_t;
#endif

#if defined (HAVE_ERRNO) && !defined (errno) && !defined (ERRNO_DECLARED)
extern int errno;
#endif

#if HAVE_CRT_EXTERNS_H
#include <crt_externs.h>
#define environ (*_NSGetEnviron ())
#elif defined (HAVE_ENVIRON) || defined (environ)
#if !defined (environ) && !defined (ENVIRON_DECLARED)
extern char **environ;
#endif
#elif defined (HAVE___ENVIRON) || defined (__environ)
#if !defined (__environ) && !defined (__ENVIRON_DECLARED)
extern char **__environ;
#endif
#define environ __environ
#endif

#if !defined (HAVE_STRSIGNAL) && !defined (strsignal)
#if defined (HAVE_SYS_SIGLIST) || defined (sys_siglist)
#if !defined (sys_siglist) && !defined (SYS_SIGLIST_DECLARED) && !defined (HAVE_DECL_SYS_SIGLIST)
extern char **sys_siglist;
#endif
#elif defined (HAVE__SYS_SIGLIST) || defined (_sys_siglist)
#if !defined (_sys_siglist) && !defined (_SYS_SIGLIST_DECLARED)
extern char **_sys_siglist;
#endif
#define sys_siglist _sys_siglist
#endif
#endif
#ifndef SIGMAX
#ifdef HAVE__SYS_NSIG
#ifndef _SYS_NSIG_DECLARED
extern int _sys_nsig;
#endif
#define SIGMAX _sys_nsig
#endif
#endif

#ifdef HAVE_TZNAME
#if !defined (tzname) && !defined (TZNAME_DECLARED)
extern char *tzname [2];
#endif
#else
static char *tzname [2] = { NULL, NULL };
#endif
#ifdef HAVE__TIMEZONE
#if !defined (_timezone) && !defined (_TIMEZONE_DECLARED)
extern long int _timezone;
#endif
#undef timezone
#define timezone _timezone
#elif defined (HAVE_TIMEZONE)
#if !defined (timezone) && !defined (TIMEZONE_DECLARED)
extern long int timezone;
#endif
#else
#define timezone 0
#endif

#undef HAVE_INPUT_SIGNALS
#if (defined (HAVE_TCGETATTR) || defined (tcgetattr)) && \
    (defined (HAVE_TCSETATTR) || defined (tcsetattr)) && defined (TCSANOW) && defined (ISIG)
#define HAVE_INPUT_SIGNALS
#endif

/* Substitutes and placeholders for declarations not present on all systems */

#ifndef O_BINARY
#define O_BINARY 0
#endif

#ifndef SSIZE_MAX
#define SSIZE_MAX 16384
#endif

#ifndef PATH_MAX
#ifdef MAX_PATH
#define PATH_MAX MAX_PATH
#else
#define PATH_MAX 2048
#endif
#endif

#ifndef MAXPATHLEN
#define MAXPATHLEN PATH_MAX
#endif

/* cf. _p_CStringStrError */
#define START_EMULATED_ERRNOS 10000  /*@@ should not conflict with existing error numbers */
#ifndef ENOSYS
#define ENOSYS (START_EMULATED_ERRNOS + 1)
#endif
#ifndef EFBIG
#define EFBIG (START_EMULATED_ERRNOS + 2)
#endif

#ifdef EINTR
#define ISEINTR(Result) ((Result) < 0 && errno == EINTR)
#else
#define ISEINTR(Result) 0
#endif

#ifndef HAVE_GETCWD
#define getcwd(buffer, size) NULL
#endif

#if !defined (HAVE_SINL) || !defined(SINL_DECLARED)
#define sinl sin
#endif
#if !defined (HAVE_COSL) || !defined(COSL_DECLARED)
#define cosl cos
#endif
#if !defined (HAVE_SQRTL) || !defined(SQRTL_DECLARED)
#define sqrtl sqrt
#endif
#if !defined (HAVE_LOGL) || !defined(LOGL_DECLARED)
#define logl log
#endif
#if !defined (HAVE_EXPL) || !defined(EXPL_DECLARED)
#define expl exp
#endif
#if !defined (HAVE_POWL) || !defined(POWL_DECLARED)
#define powl pow
#endif
#if !defined (HAVE_ASINL) || !defined(ASINL_DECLARED)
#define asinl asin
#endif
#if !defined (HAVE_ACOSL) || !defined(ACOSL_DECLARED)
#define acosl acos
#endif
#if !defined (HAVE_ATANL) || !defined(ATANL_DECLARED)
#define atanl atan
#endif
#if !defined (HAVE_FREXPL) || !defined(FREXPL_DECLARED)
#define frexpl frexp
#endif

/* Dos systems only know permissions (partly) for user, not for group and others */
#ifndef S_ISUID
#define S_ISUID 0
#endif
#ifndef S_ISGID
#define S_ISGID 0
#endif
#ifndef S_ISVTX
#define S_ISVTX 0
#endif
#ifndef S_IRGRP
#define S_IRGRP S_IRUSR
#endif
#ifndef S_IROTH
#define S_IROTH S_IRUSR
#endif
#ifndef S_IWGRP
#define S_IWGRP S_IWUSR
#endif
#ifndef S_IWOTH
#define S_IWOTH S_IWUSR
#endif
#ifndef S_IXGRP
#define S_IXGRP S_IXUSR
#endif
#ifndef S_IXOTH
#define S_IXOTH S_IXUSR
#endif
#ifndef S_ISLNK
#define S_ISLNK(f) 0
#endif
#ifndef S_ISCHR
#define S_ISCHR(f) 0
#endif
#ifndef S_ISBLK
#define S_ISBLK(f) 0
#endif
#ifndef S_ISFIFO
#define S_ISFIFO(f) 0
#endif
#ifndef S_ISSOCK
#define S_ISSOCK(f) 0
#endif

#ifndef WIFEXITED
#define WIFEXITED(S) (((S) & 0xff) == 0)
#endif
#ifndef WEXITSTATUS
#define WEXITSTATUS(S) ((((unsigned) (S)) & 0xff00) >> 8)
#endif
#ifndef WIFSIGNALED
#define WIFSIGNALED(S) (((S) & 0xff) != 0 && ((S) & 0xff) != 0x7f)
#endif
#ifndef WTERMSIG
#define WTERMSIG(S) ((S) & 0x7f)
#endif
#ifndef WIFSTOPPED
#define WIFSTOPPED(S) (((S) & 0xff) == 0x7f)
#endif
#ifndef WSTOPSIG
#define WSTOPSIG(S) ((((unsigned) (S)) & 0xff00) >> 8)
#endif

#ifndef SA_RESTART
#define SA_RESTART 0
#endif
#ifndef SV_INTERRUPT
#define SV_INTERRUPT 0
#endif

#ifndef SIG_DFL
#define SIG_DFL ((void *) 0)
#endif
#ifndef SIG_IGN
#define SIG_IGN ((void *) 1)
#endif
#ifndef SIG_ERR
#define SIG_ERR ((void *) -1)
#endif

#ifndef SIGHUP
#define SIGHUP 0
#endif
#ifndef SIGINT
#define SIGINT 0
#endif
#ifndef SIGQUIT
#define SIGQUIT 0
#endif
#ifndef SIGILL
#define SIGILL 0
#endif
#ifndef SIGABRT
#define SIGABRT 0
#endif
#ifndef SIGFPE
#define SIGFPE 0
#endif
#ifndef SIGKILL
#define SIGKILL 0
#endif
#ifndef SIGSEGV
#define SIGSEGV 0
#endif
#ifndef SIGPIPE
#define SIGPIPE 0
#endif
#ifndef SIGALRM
#define SIGALRM 0
#endif
#ifndef SIGTERM
#define SIGTERM 0
#endif
#ifndef SIGUSR1
#define SIGUSR1 0
#endif
#ifndef SIGUSR2
#define SIGUSR2 0
#endif
#ifndef SIGCHLD
#ifdef SIGCLD
#define SIGCHLD SIGCLD
#else
#define SIGCHLD 0
#endif
#endif
#ifndef SIGCONT
#define SIGCONT 0
#endif
#ifndef SIGSTOP
#define SIGSTOP 0
#endif
#ifndef SIGTSTP
#define SIGTSTP 0
#endif
#ifndef SIGTTIN
#define SIGTTIN 0
#endif
#ifndef SIGTTOU
#define SIGTTOU 0
#endif
#ifndef SIGTRAP
#define SIGTRAP 0
#endif
#ifndef SIGIOT
#define SIGIOT 0
#endif
#ifndef SIGEMT
#define SIGEMT 0
#endif
#ifndef SIGBUS
#define SIGBUS 0
#endif
#ifndef SIGSYS
#define SIGSYS 0
#endif
#ifndef SIGSTKFLT
#define SIGSTKFLT 0
#endif
#ifndef SIGURG
#define SIGURG 0
#endif
#ifndef SIGIO
#define SIGIO 0
#endif
#ifndef SIGPOLL
#define SIGPOLL 0
#endif
#ifndef SIGXCPU
#define SIGXCPU 0
#endif
#ifndef SIGXFSZ
#define SIGXFSZ 0
#endif
#ifndef SIGVTALRM
#define SIGVTALRM 0
#endif
#ifndef SIGPROF
#define SIGPROF 0
#endif
#ifndef SIGPWR
#define SIGPWR 0
#endif
#ifndef SIGINFO
#define SIGINFO 0
#endif
#ifndef SIGLOST
#define SIGLOST 0
#endif
#ifndef SIGWINCH
#define SIGWINCH 0
#endif

#ifndef ILL_RESAD_FAULT
#define ILL_RESAD_FAULT (-1)
#endif
#ifndef ILL_PRIVIN_FAULT
#define ILL_PRIVIN_FAULT (-1)
#endif
#ifndef ILL_RESOP_FAULT
#define ILL_RESOP_FAULT (-1)
#endif
#ifndef FPE_INTOVF_TRAP
#define FPE_INTOVF_TRAP (-1)
#endif
#ifndef FPE_INTDIV_TRAP
#define FPE_INTDIV_TRAP (-1)
#endif
#ifndef FPE_SUBRNG_TRAP
#define FPE_SUBRNG_TRAP (-1)
#endif
#ifndef FPE_FLTOVF_TRAP
#ifdef FPE_FLTOVF_FAULT
#define FPE_FLTOVF_TRAP FPE_FLTOVF_FAULT
#else
#define FPE_FLTOVF_TRAP (-1)
#endif
#endif
#ifndef FPE_FLTDIV_TRAP
#ifdef FPE_FLTDIV_FAULT
#define FPE_FLTDIV_TRAP FPE_FLTDIV_FAULT
#else
#define FPE_FLTDIV_TRAP (-1)
#endif
#endif
#ifndef FPE_FLTUND_TRAP
#ifdef FPE_FLTUND_FAULT
#define FPE_FLTUND_TRAP FPE_FLTUND_FAULT
#else
#define FPE_FLTUND_TRAP (-1)
#endif
#endif
#ifndef FPE_DECOVF_TRAP
#define FPE_DECOVF_TRAP (-1)
#endif

#ifndef MAP_FAILED
#define MAP_FAILED ((void *) -1)
#endif

typedef void (*TSignalHandler) (int);

TSignalHandler _p_SIG_DFL = SIG_DFL, _p_SIG_IGN = SIG_IGN, _p_SIG_ERR = SIG_ERR;

int _p_SIGHUP    = SIGHUP,    _p_SIGINT  = SIGINT,  _p_SIGQUIT  = SIGQUIT,
    _p_SIGILL    = SIGILL,    _p_SIGABRT = SIGABRT, _p_SIGFPE   = SIGFPE,
    _p_SIGKILL   = SIGKILL,   _p_SIGSEGV = SIGSEGV, _p_SIGPIPE  = SIGPIPE,
    _p_SIGALRM   = SIGALRM,   _p_SIGTERM = SIGTERM, _p_SIGUSR1  = SIGUSR1,
    _p_SIGUSR2   = SIGUSR2,   _p_SIGCHLD = SIGCHLD, _p_SIGCONT  = SIGCONT,
    _p_SIGSTOP   = SIGSTOP,   _p_SIGTSTP = SIGTSTP, _p_SIGTTIN  = SIGTTIN,
    _p_SIGTTOU   = SIGTTOU,   _p_SIGTRAP = SIGTRAP, _p_SIGIOT   = SIGIOT,
    _p_SIGEMT    = SIGEMT,    _p_SIGBUS  = SIGBUS,  _p_SIGSYS   = SIGSYS,
    _p_SIGSTKFLT = SIGSTKFLT, _p_SIGURG  = SIGURG,  _p_SIGIO    = SIGIO,
    _p_SIGPOLL   = SIGPOLL,   _p_SIGXCPU = SIGXCPU, _p_SIGXFSZ  = SIGXFSZ,
    _p_SIGVTALRM = SIGVTALRM, _p_SIGPROF = SIGPROF, _p_SIGPWR   = SIGPWR,
    _p_SIGINFO   = SIGINFO,   _p_SIGLOST = SIGLOST, _p_SIGWINCH = SIGWINCH;

int _p_FPE_INTOVF_TRAP  = FPE_INTOVF_TRAP,
    _p_FPE_INTDIV_TRAP  = FPE_INTDIV_TRAP,
    _p_FPE_SUBRNG_TRAP  = FPE_SUBRNG_TRAP,
    _p_FPE_FLTOVF_TRAP  = FPE_FLTOVF_TRAP,
    _p_FPE_FLTDIV_TRAP  = FPE_FLTDIV_TRAP,
    _p_FPE_FLTUND_TRAP  = FPE_FLTUND_TRAP,
    _p_FPE_DECOVF_TRAP  = FPE_DECOVF_TRAP;

#ifndef HAVE_OFF_T
typedef int off_t;
#endif
#ifndef HAVE_OFF64_T
#ifdef HAVE___OFF64_T
typedef __off64_t off64_t;
#elif defined (HAVE_LOFF_T)
typedef loff_t off64_t;
#elif defined (HAVE_OFFSET_T)
typedef offset_t off64_t;
#endif
#endif

#if defined (HAVE_STRSIGNAL) && !defined (strsignal) && !defined (STRSIGNAL_DECLARED)
extern char *strsignal (int);
#endif
#if defined (HAVE_LLSEEK) && !defined (LLSEEK_DECLARED)
extern off64_t llseek (int, off64_t, int);
#endif
#if defined (HAVE_LSEEK64) && !defined (LSEEK64_DECLARED)
extern off64_t lseek64 (int, off64_t, int);
#endif
#ifdef HAVE_STRUCT_STAT64
#if defined (HAVE_LSTAT64) && !defined (LSTAT64_DECLARED)
extern int lstat64 (const char *, struct stat64 *);
#endif
#if defined (HAVE_STAT64) && !defined (STAT64_DECLARED)
extern int stat64 (const char *, struct stat64 *);
#endif
#if defined (HAVE_FSTAT64) && !defined (FSTAT64_DECLARED)
extern int fstat64 (int, struct stat64 *);
#endif
#endif
#if defined (HAVE_FTRUNCATE64) && !defined (FTRUNCATE64_DECLARED)
extern int ftruncate64 (int, off64_t);
#endif
#if defined (HAVE_OPEN64) && !defined (OPEN64_DECLARED)
extern int open64 (const char *, int, mode_t);
#endif
#ifdef HAVE_OPEN64
#define open open64
#endif

#ifdef HAVE_STRUCT_STAT64
#ifdef HAVE_STAT64
#undef stat
#define stat stat64  /* also applies to struct stat! */
#undef HAVE_STAT
#define HAVE_STAT 1
#endif
#ifdef HAVE_LSTAT64
#undef lstat
#define lstat lstat64
#undef HAVE_LSTAT
#define HAVE_LSTAT 1
#endif
#ifdef HAVE_FSTAT64
#undef fstat
#define fstat fstat64
#undef HAVE_FSTAT
#define HAVE_FSTAT 1
#endif
#endif
#ifndef HAVE_LSTAT
#define lstat stat
#endif

#if defined (HAVE_USLEEP) && !defined (USLEEP_DECLARED)
extern void usleep (unsigned long usec);
#endif

#if defined (HAVE_SETENV) && !defined (SETENV_DECLARED)
extern int setenv (char *name, char *value, int overwrite);
#endif

#if defined (HAVE_UNSETENV) && !defined (UNSETENV_DECLARED)
extern void unsetenv (char *name);
#endif

#if defined (HAVE_SETREUID) && !defined (SETREUID_DECLARED)
int setreuid (int ruid, int euid);
#endif

#if defined (HAVE_SETREGID) && !defined (SETREGID_DECLARED)
int setregid (int rgid, int egid);
#endif

/* Constants used in Pascal */
#define False 0
#define True  1

/* Types used in Pascal */

/* These types are hard-coded in the compiler. Do not change here. */
typedef unsigned char Boolean;
typedef unsigned char Char;
typedef long long int UnixTimeType;
typedef long long int FileSizeType;
typedef long long int MicroSecondTimeType;

typedef char **PCStrings;

typedef struct
{
  long long int BlockSize, BlocksTotal, BlocksFree;
  int FilesTotal, FilesFree;
} StatFSBuffer;

typedef struct
{
  int Handle;
  Boolean Read, Write, Exception;
} InternalSelectType;

typedef struct
{
  void  *Result;
  void  *Internal1;
  char **Internal2;
  int    Internal3;
} GlobBuffer;

typedef struct
{
  char *UserName, *RealName, *Password, *HomeDirectory, *Shell;
  int UID, GID;
} TCPasswordEntry, *PCPasswordEntries;

/* Declarations from RTS Pascal files needed here */

#define UNUSED __attribute__ ((__unused__))
#define NORETURN __attribute__ ((noreturn))

/* heap.pas */
void *_p_New (size_t);
void _p_Dispose (const void *);
void *_p_InternalNew (size_t);
void _p_ReAllocMem (void **, size_t);

/* string1.pas */
extern const char **_p_CParameters;
size_t _p_CStringLength (const char *);
char *_p_CStringNew (const char *);
int _p_CStringComp (const char *, const char *);
char *_p_CStringLCopy (char *, const char *, size_t);
char *_p_CStringChPos (const char *, char);

/* fname.pas */
extern char _p_DirSeparatorVar;

/* move.pas */
void _p_Move (const void *, void *, size_t);

/* error.pas */
void _p_AtExit (void (*proc) (void));
void _p_SetReturnAddress (void *);
void _p_RestoreReturnAddress (void);
void _p_RuntimeError (int) NORETURN;
void _p_RuntimeErrorErrNo (int) NORETURN;
#define DO_RETURN_ADDRESS(stmt) \
do \
  { \
    _p_SetReturnAddress (__builtin_return_address (0)); \
    stmt; \
    _p_RestoreReturnAddress (); \
  } \
while (0)
#define _p_RuntimeError(n)      DO_RETURN_ADDRESS (_p_RuntimeError (n))
#define _p_RuntimeErrorErrNo(n) DO_RETURN_ADDRESS (_p_RuntimeErrorErrNo (n))

/* This is to suppress warnings about missing prototypes for C functions.
   Since they are only called from Pascal code (and possibly this same C file),
   we actually wouldn't need a prototype, but we can't declare them static. */
#define GLOBAL(decl) decl; decl
#define GLOBAL_ATTR(decl, attr) decl __attribute__ ((attr)); decl
#define ignorable

/** Mathematical routines */

/*@internal*/

GLOBAL_ATTR (double _p_Sin (double x), const)
{
  return sin (x);
}

GLOBAL_ATTR (double _p_Cos (double x), const)
{
  return cos (x);
}

GLOBAL_ATTR (double _p_ArcSin (double x), const)
{
  return asin (x);
}

GLOBAL_ATTR (double _p_ArcCos (double x), const)
{
  return acos (x);
}

GLOBAL_ATTR (double _p_ArcTan (double x), const)
{
  return atan (x);
}

GLOBAL_ATTR (double _p_SqRt (double x), const)
{
  if (x < 0.0) _p_RuntimeError (708);  /* argument to `SqRt' is < 0 */
  return sqrt (x);
}

GLOBAL_ATTR (double _p_Ln (double x), const)
{
  if (x <= 0.0) _p_RuntimeError (707);  /* argument to `Ln' is <= 0 */
  return log (x);
}

GLOBAL_ATTR (double _p_Exp (double x), const)
{
  double rval;
  errno = 0;
  rval = exp (x);
  if (errno) _p_RuntimeErrorErrNo (700);  /* error in exponentiation */
  return rval;
}

GLOBAL_ATTR (double _p_Power (double x, double y), const)
{
  double rval;
  if (x < 0.0) _p_RuntimeErrorErrNo (701);  /* left operand of `**' is negative */
  if (x == 0.0 && y <= 0.0) _p_RuntimeError (702);  /* left argument of `**' is 0 while right argument is <= 0 */
  errno = 0;
  rval = (x == 0.0) ? 0.0 : (y == 0.0) ? 1.0 : pow (x, y);
  if (errno) _p_RuntimeErrorErrNo (700);  /* error in exponentiation */
  return rval;
}

GLOBAL_ATTR (double _p_InternalHypot (double x UNUSED, double y UNUSED), const)
{
  #ifdef HAVE_HYPOT
  return hypot (x, y);
  #else
  return 0;
  #endif
}

GLOBAL_ATTR (double _p_InternalLn1Plus (double x UNUSED), const)
{
  #ifdef HAVE_LOG1P
  return log1p (x);
  #else
  return 0;
  #endif
}

GLOBAL_ATTR (long double _p_LongReal_Sin (long double x), const)
{
  return sinl (x);
}

GLOBAL_ATTR (long double _p_LongReal_Cos (long double x), const)
{
  return cosl (x);
}

GLOBAL_ATTR (long double _p_LongReal_ArcSin (long double x), const)
{
  return asinl (x);
}

GLOBAL_ATTR (long double _p_LongReal_ArcCos (long double x), const)
{
  return acosl (x);
}

GLOBAL_ATTR (long double _p_LongReal_ArcTan (long double x), const)
{
  return atanl (x);
}

GLOBAL_ATTR (long double _p_LongReal_SqRt (long double x), const)
{
  if (x < 0.0) _p_RuntimeError (708);  /* argument to `SqRt' is < 0 */
  return sqrtl (x);
}

GLOBAL_ATTR (long double _p_LongReal_Ln (long double x), const)
{
  if (x <= 0.0) _p_RuntimeError (707);  /* argument to `Ln' is <= 0 */
  return logl (x);
}

GLOBAL_ATTR (long double _p_LongReal_Exp (long double x), const)
{
  long double rval;
  errno = 0;
  rval = expl (x);
  if (errno) _p_RuntimeErrorErrNo (700);  /* error in exponentiation */
  return rval;
}

GLOBAL_ATTR (long double _p_LongReal_Power (long double x, long double y), const)
{
  long double rval;
  if (x < 0.0) _p_RuntimeErrorErrNo (701);  /* left operand of `**' is negative */
  if (x == 0.0 && y <= 0.0) _p_RuntimeError (702);  /* left argument of `**' is 0 while right argument is <= 0 */
  errno = 0;
  rval = (x == 0.0) ? 0.0 : (y == 0.0) ? 1.0 : powl (x, y);
  if (errno) _p_RuntimeErrorErrNo (700);  /* error in exponentiation */
  return rval;
}

/*@endinternal*/

GLOBAL_ATTR (double _p_SinH (double x), const)
{
  return sinh (x);
}

GLOBAL_ATTR (double _p_CosH (double x), const)
{
  return cosh (x);
}

GLOBAL_ATTR (double _p_ArcTan2 (double y, double x), const)
{
  return atan2 (y, x);
}

GLOBAL_ATTR (Boolean _p_IsInfinity (long double x), const)
{
  /* Don't use isinf() -- it might fail on long doubles */
  #if defined (HAVE_ISINFL) && defined (ISINFL_DECLARED)
  return !!isinfl (x);
  #else
  long double y = x / 2;
  return (y != 0) && (y + y == y);
  #endif
}

GLOBAL_ATTR (Boolean _p_IsNotANumber (long double x), const)
{
  /* Don't use isnan() -- it might fail on long doubles */
  #if defined (HAVE_ISNANL) && defined (ISNANL_DECLARED)
  return !!isnanl (x);
  #else
  return !!(x == 0) + !!(x < 0) + !!(x > 0) != 1;
  #endif
}

GLOBAL (void _p_SplitReal (long double x, int *Exponent, long double *Mantissa))
{
  /* @@ Work-around for a bug on some systems, e.g. MIPS/IRIX */
  static int frexpl_bug = 0;
  if (!frexpl_bug)
    {
      #define IMPOSSIBLE_EXPONENT 0x7fffffff
      *Exponent = IMPOSSIBLE_EXPONENT;
      *Mantissa = frexpl (x, Exponent);
      if (*Exponent == IMPOSSIBLE_EXPONENT)
        frexpl_bug = 1;
      else
        return;
    }
  *Mantissa = frexp (x, Exponent);
}

/** Character routines */

extern Boolean _p_FakeHighLetters;

/*@internal*/
/** Convert a character to upper case, according to the current
    locale.
    Except in `--borland-pascal' mode, `UpCase' does the same. */
GLOBAL_ATTR (Char _p_UpCase (Char ch), const)
{
  return toupper (ch);
}
/*@endinternal*/

/** Convert a character to lower case, according to the current
    locale. */
GLOBAL_ATTR (Char _p_LoCase (Char ch), const)
{
  return tolower (ch);
}

GLOBAL_ATTR (Boolean _p_IsUpCase (Char ch), const)
{
  return isupper (ch) != 0;
}

GLOBAL_ATTR (Boolean _p_IsLoCase (Char ch), const)
{
  return islower (ch) != 0;
}

GLOBAL_ATTR (Boolean _p_IsAlpha (Char ch), const)
{
  return isalpha (ch) != 0 || (_p_FakeHighLetters && ch > 0xa0);
}

GLOBAL_ATTR (Boolean _p_IsAlphaNum (Char ch), const)
{
  return isalnum (ch) != 0 || (_p_FakeHighLetters && ch > 0xa0);
}

GLOBAL_ATTR (Boolean _p_IsAlphaNumUnderscore (Char ch), const)
{
  return ch == '_' || _p_IsAlphaNum (ch);
}

GLOBAL_ATTR (Boolean _p_IsSpace (Char ch), const)
{
  return isspace (ch) != 0;
}

GLOBAL_ATTR (Boolean _p_IsPrintable (Char ch), const)
{
  return isprint (ch) != 0 || (_p_FakeHighLetters && ch > 0xa0);
}

/** Time routines */

#ifdef __GO32__
#include <dpmi.h>
#include <unistd.h>
#include <dos.h>

static void usleep2 (unsigned musec)
{
  static int doze = -1;
  if (doze < 0)
    {
      _go32_dpmi_registers dpmiregs;
      dpmiregs.x.ax = 0x1600;
      dpmiregs.x.ss = dpmiregs.x.sp = dpmiregs.x.flags = 0;
      _go32_dpmi_simulate_int (0x2f, &dpmiregs);
      doze = dpmiregs.h.al > 2 && dpmiregs.h.al != 0x80 && dpmiregs.h.al != 0xff
             && (dpmiregs.h.al > 3 || dpmiregs.h.ah > 0);
    }
  if (doze)
    usleep ((musec >= 11264) ? musec : 11264);
  else
    delay (musec / 1000);
}
#define usleep usleep2
#endif

/** Sleep for a given number of seconds. */
GLOBAL (void _p_Sleep (int Seconds))
{
  int i = Seconds;
  errno = 0;
  #if defined (HAVE_SLEEP) && defined (SLEEP_DECLARED)
  do
    i = sleep (i);
  while (i != 0);
  #elif defined (HAVE__SLEEP)
  _sleep (i);
  #else
  errno = ENOSYS;
  #endif
}

/** Sleep for a given number of microseconds. */
GLOBAL (void _p_SleepMicroSeconds (int MicroSeconds))
{
  if (MicroSeconds <= 0) return;
  #ifdef HAVE_USLEEP
  usleep (MicroSeconds);
  #else
  _p_Sleep ((MicroSeconds + 999999) / 1000000);
  #endif
}

/** Set an alarm timer. */
GLOBAL (int _p_Alarm (int Seconds UNUSED))
{
  #ifdef HAVE_ALARM
  errno = 0;
  return alarm (Seconds);
  #else
  errno = ENOSYS;
  return -1;
  #endif
}

/** Convert a Unix time value to broken-down local time.
    All parameters except Time may be Null. */
GLOBAL (void _p_UnixTimeToTime (UnixTimeType Time, int *Year, int *Month, int *Day, int *Hour, int *Minute, int *Second,
                                int *TimeZone, Boolean *DST, char **TZName1, char **TZName2))
{
  if (Time >= 0)
    {
      time_t seconds = (time_t) Time;
      struct tm *t = localtime (&seconds);
      if (Year)   { *Year     = t->tm_year; if (*Year < 1000) *Year += 1900; }
      if (Month)    *Month    = t->tm_mon + 1;  /* 1 = January */
      if (Day)      *Day      = t->tm_mday;
      if (Hour)     *Hour     = t->tm_hour;
      if (Minute)   *Minute   = t->tm_min;
      if (Second)   *Second   = t->tm_sec;
      #ifdef HAVE_TM_GMTOFF
      if (TimeZone) *TimeZone = t->tm_gmtoff;
      #else
      if (TimeZone) *TimeZone = -timezone;
      #endif
      #ifdef HAVE_TM_ISDST
      if (DST) *DST = t->tm_isdst > 0;
      #else
      if (DST) *DST = False;
      #endif
      if (TZName1)  *TZName1  = tzname[0];
      if (TZName2)  *TZName2  = tzname[1];
    }
  else
    {
      if (Year)     *Year     = -1;
      if (Month)    *Month    = -1;
      if (Day)      *Day      = -1;
      if (Hour)     *Hour     = -1;
      if (Minute)   *Minute   = -1;
      if (Second)   *Second   = -1;
      if (TimeZone) *TimeZone = 0;
      if (DST)      *DST      = False;
      if (TZName1)  *TZName1  = NULL;
      if (TZName2)  *TZName2  = NULL;
    }
}

/** Convert broken-down local time to a Unix time value. */
GLOBAL (UnixTimeType _p_TimeToUnixTime (int Year, int Month, int Day, int Hour, int Minute, int Second))
{
  struct tm gnu;  /* It is a trademark after all }:--)= */
  memset (&gnu, 0, sizeof (gnu));
  gnu.tm_isdst = -1;
  gnu.tm_year  = Year - 1900;
  gnu.tm_mon   = Month - 1;  /* 1 = January */
  gnu.tm_mday  = Day;
  gnu.tm_hour  = Hour;
  gnu.tm_min   = Minute;
  gnu.tm_sec   = Second;
  return (UnixTimeType) mktime (&gnu);
}

/** Get the real time. MicroSecond can be Null and is ignored then. */
GLOBAL (UnixTimeType _p_GetUnixTime (int *MicroSecond))
{
  #ifdef HAVE_GETTIMEOFDAY
  struct timeval tval;
  errno = 0;
  if (!gettimeofday (&tval, 0))
    {
      if (MicroSecond) *MicroSecond = tval.tv_usec;
      return tval.tv_sec;
    }
  #elif defined (HAVE_TIME)
  if (MicroSecond) *MicroSecond = 0;
  return (UnixTimeType) time ((time_t *) 0);
  #endif
  if (MicroSecond) *MicroSecond = 0;
  errno = ENOSYS;
  return -1;
}

#ifndef HAVE_GETRUSAGE
static clock_t InitialClocks = 0;
#endif

/** Get the CPU time used. MicroSecond can be Null and is ignored
    then. */
GLOBAL (int _p_GetCPUTime (int *MicroSecond))
{
  #ifdef HAVE_GETRUSAGE
  int ms;
  struct rusage u;
  getrusage (RUSAGE_SELF, &u);
  ms = u.ru_utime.tv_usec + u.ru_stime.tv_usec;
  if (MicroSecond) *MicroSecond = ms % 1000000;
  return (int) u.ru_utime.tv_sec + u.ru_stime.tv_sec + ms / 1000000;
  #else
  clock_t clocks = clock () - InitialClocks;
  if (MicroSecond) *MicroSecond = ((int) ((((long long int) clocks) * 1000000) / CLOCKS_PER_SEC)) % 1000000;
  return (int) (clocks / CLOCKS_PER_SEC);
  #endif
}

/*@internal*/
GLOBAL (void _p_InitTime (void))
{
  #ifndef HAVE_GETRUSAGE
  InitialClocks = clock ();
  #endif
}

GLOBAL (int _p_CFormatTime (UnixTimeType Time UNUSED, char *Format UNUSED, char *Buf UNUSED, int Size UNUSED))
{
  #ifdef HAVE_STRFTIME
  time_t seconds = (time_t) Time;
  struct tm *t = localtime (&seconds);
  int Res;
  /* cf. the recommendations in (libc)strftime on how to check for errors */
  Buf[0] = 1;
  Res = strftime (Buf, Size, Format, t);
  if (Res == 0 && Buf[0] != 0) Res = -1;
  return Res;
  #else
  return -1;
  #endif
}
/*@endinternal*/

/** Signal and process routines */

/** Extract information from the status returned by PWait */
GLOBAL_ATTR (Boolean _p_StatusExited (int Status UNUSED), const)
{
  return !!WIFEXITED (Status);
}

GLOBAL_ATTR (int _p_StatusExitCode (int Status UNUSED), const)
{
  return WEXITSTATUS (Status);
}

GLOBAL_ATTR (Boolean _p_StatusSignaled (int Status UNUSED), const)
{
  return !!WIFSIGNALED (Status);
}

GLOBAL_ATTR (int _p_StatusTermSignal (int Status UNUSED), const)
{
  return WTERMSIG (Status);
}

GLOBAL_ATTR (Boolean _p_StatusStopped (int Status UNUSED), const)
{
  return !!WIFSTOPPED (Status);
}

GLOBAL_ATTR (int _p_StatusStopSignal (int Status UNUSED), const)
{
  return WSTOPSIG (Status);
}

/** Install a signal handler and optionally return the previous
    handler. OldHandler and OldRestart may be Null. */
GLOBAL (Boolean _p_InstallSignalHandler (int Signal, TSignalHandler Handler, Boolean Restart UNUSED, Boolean UnlessIgnored UNUSED,
  TSignalHandler *OldHandler, Boolean *OldRestart))
{
  TSignalHandler aOldHandler = SIG_ERR;
  int aOldRestart = False, Result = False;
  errno = 0;
  if (Signal != 0 && Handler != SIG_ERR)
    {
      #ifdef HAVE_SIGACTION
      struct sigaction Action, OldAction;
      Action.sa_handler = Handler;
      sigemptyset (&Action.sa_mask);
      Action.sa_flags = Restart ? SA_RESTART : 0;
      if (!UnlessIgnored)
        Result = sigaction (Signal, &Action, &OldAction) == 0;
      else if (sigaction (Signal, NULL, &OldAction) == 0)
        {
          if (OldAction.sa_handler == SIG_IGN)
            Result = True;
          else
            Result = sigaction (Signal, &Action, &OldAction) == 0;
        }
      aOldHandler = OldAction.sa_handler;
      aOldRestart = !!(OldAction.sa_flags & SA_RESTART);
      #elif defined (HAVE_SIGVEC)
      struct sigvec Action, OldAction;
      Action.sv_handler = Handler;
      Action.sv_mask = 0;
      Action.sv_flags = Restart ? 0 : SV_INTERRUPT;
      if (!UnlessIgnored)
        Result = sigvec (Signal, &Action, &OldAction) == 0;
      else if (sigvec (Signal, NULL, &OldAction) == 0)
        {
          if (OldAction.sv_handler == SIG_IGN)
            Result = True;
          else
            Result = sigvec (Signal, &Action, &OldAction) == 0;
        }
      aOldHandler = OldAction.sv_handler;
      aOldRestart = !(OldAction.sv_flags & SV_INTERRUPT);
      #elif defined (HAVE_SIGNAL)
      aOldHandler = signal (Signal, Handler);
      if (aOldHandler != SIG_ERR)
        {
          if (UnlessIgnored && aOldHandler == SIG_IGN)
            signal (Signal, SIG_IGN);
          #ifdef HAVE_SIGINTERRUPT
          else
            siginterrupt (Signal, !Restart);
          #endif
          Result = True;
        }
      #else
      errno = ENOSYS;
      #endif
    }
  if (OldHandler)
    *OldHandler = aOldHandler;
  if (OldRestart)
    *OldRestart = aOldRestart;
  return Result;
}

/** Block or unblock a signal. */
GLOBAL (void _p_BlockSignal (int Signal UNUSED, Boolean Block UNUSED))
{
  #ifdef HAVE_SIGPROCMASK
  sigset_t sigset;
  errno = 0;
  sigemptyset (&sigset);
  sigaddset (&sigset, Signal);
  if (Block)
    sigprocmask (SIG_BLOCK, &sigset, NULL);
  else
    sigprocmask (SIG_UNBLOCK, &sigset, NULL);
  #elif defined (HAVE_SIGBLOCK) && defined (HAVE_SIGSETMASK)
  if (Block)
    sigblock (sigmask (Signal));
  else
    sigsetmask (sigblock (0) & ~(sigmask (Signal)));
  #else
  errno = ENOSYS;
  #endif
}

/** Test whether a signal is blocked. */
GLOBAL (Boolean _p_SignalBlocked (int Signal UNUSED))
{
  #ifdef HAVE_SIGPROCMASK
  sigset_t sigset, oldsigset;
  errno = 0;
  sigemptyset (&sigset);
  return sigprocmask (SIG_BLOCK, &sigset, &oldsigset) == 0 &&
         sigismember (&oldsigset, Signal);
  #elif defined (HAVE_SIGBLOCK)
  return (sigblock (0) & (sigmask (Signal))) != 0;
  #else
  errno = ENOSYS;
  return False;
  #endif
}

/** Sends a signal to a process. Returns True if successful. If Signal
    is 0, it doesn't send a signal, but still checks whether it would
    be possible to send a signal to the given process. */
GLOBAL (Boolean _p_Kill (int PID UNUSED, int Signal UNUSED))
{
  #ifdef HAVE_KILL
  errno = 0;
  return kill (PID, Signal) == 0;
  #else
  errno = ENOSYS;
  return False;
  #endif
}

/** Constant for WaitPID */
enum {
  AnyChild = -1
};

/** Waits for a child process with the given PID (or any child process
    if PID = AnyChild) to terminate or be stopped. Returns the PID of
    the process. WStatus will contain the status and can be evaluated
    with StatusExited etc.. If nothing happened, and Block is False,
    the function will return 0, and WStatus will be 0. If an error
    occurred (especially on single tasking systems where WaitPID is
    not possible), the function will return a negative value, and
    WStatus will be 0. */
GLOBAL (int _p_WaitPID (int PID UNUSED, int *WStatus, Boolean Block UNUSED))
{
  int wpid;
  #ifdef HAVE_WAITPID
  errno = 0;
  do
    wpid = waitpid (PID, WStatus, Block ? 0 : WNOHANG);
  while (ISEINTR (wpid));
  #else
  errno = ENOSYS;
  *WStatus = 0;
  wpid = -1;
  #endif
  if (wpid <= 0) *WStatus = 0;
  return wpid;
}

/** Returns the process ID. */
GLOBAL (int _p_ProcessID (void))
{
  #ifdef HAVE_GETPID
  errno = 0;
  return getpid ();
  #else
  errno = ENOSYS;
  return 0;
  #endif
}

/** Returns the process group. */
GLOBAL (int _p_ProcessGroup (void))
{
  #ifdef HAVE_GETPGRP
  errno = 0;
  #ifdef GETPGRP_ARG
  return getpgrp (0);
  #else
  return getpgrp ();
  #endif
  #elif defined (HAVE_GETPGID)
  errno = 0;
  return getpgid (0);
  #else
  errno = ENOSYS;
  return 0;
  #endif
}

/** Returns the real or effective user ID of the process. */
GLOBAL (int _p_UserID (Boolean Effective UNUSED))
{
  errno = 0;
  #ifdef HAVE_GETEUID
  if (Effective) return geteuid ();
  #endif
  #ifdef HAVE_GETUID
  return getuid ();
  #else
  errno = ENOSYS;
  return 0;
  #endif
}

/** Tries to change the real and/or effective user ID. */
GLOBAL (Boolean _p_SetUserID (int Real UNUSED, int Effective UNUSED))
{
  errno = 0;
  #ifdef HAVE_SETREUID
  return setreuid (Real, Effective) == 0;
  #elif defined(HAVE_SETUID)
  return setuid (Effective) == 0;
  #else
  errno = ENOSYS;
  return False;
  #endif
}

/** Returns the real or effective group ID of the process. */
GLOBAL (int _p_GroupID (Boolean Effective UNUSED))
{
  errno = 0;
  #ifdef HAVE_GETEGID
  if (Effective) return getegid ();
  #endif
  #ifdef HAVE_GETGID
  return getgid ();
  #else
  errno = ENOSYS;
  return 0;
  #endif
}

/** Tries to change the real and/or effective group ID. */
GLOBAL (Boolean _p_SetGroupID (int Real UNUSED, int Effective UNUSED))
{
  errno = 0;
  #ifdef HAVE_SETREGID
  return setregid (Real, Effective) == 0;
  #elif defined(HAVE_SETGID)
  return setgid (Effective) == 0;
  #else
  errno = ENOSYS;
  return False;
  #endif
}

/** Low-level file routines. Mostly for internal use. */

/** Get information about a file system. */
GLOBAL (Boolean _p_StatFS (char *Path UNUSED, StatFSBuffer *Buf))
{
  int Result;
  #ifdef HAVE_STATVFS
  struct statvfs b;
  errno = 0;
  Result = statvfs (Path, &b);
  Buf->BlockSize   = (long long int) b.f_frsize;
  Buf->BlocksTotal = (long long int) b.f_blocks;
  Buf->BlocksFree  = (long long int) b.f_bavail;
  Buf->FilesTotal  = (int) b.f_files;
  Buf->FilesFree   = (int) b.f_favail;
  #elif defined (HAVE_STATFS)
  struct statfs b;
  errno = 0;
  Result = statfs (Path, &b);
  Buf->BlockSize   = (long long int) b.f_bsize;
  Buf->BlocksTotal = (long long int) b.f_blocks;
  Buf->BlocksFree  = (long long int) b.f_bavail;
  Buf->FilesTotal  = (int) b.f_files;
  Buf->FilesFree   = (int) b.f_ffree;
  #else
  Result = -1;
  errno = ENOSYS;
  #endif
  if (Result == 0) return True;
  Buf->BlockSize = 0;
  Buf->BlocksTotal = 0;
  Buf->BlocksFree = 0;
  Buf->FilesTotal = 0;
  Buf->FilesFree = 0;
  return False;
}

GLOBAL (DIR *_p_CStringOpenDir (char *DirName))
{
  errno = 0;
  return opendir (DirName);
}

GLOBAL (char *_p_CStringReadDir (DIR *Dir))
{
  struct dirent *d = readdir (Dir);
  return d ? d->d_name : NULL;
}

GLOBAL (void _p_CStringCloseDir (DIR *Dir))
{
  if (Dir) closedir (Dir);
}

/** Returns the value of the symlink FileName in a CString allocated
    from the heap. Returns nil if it is no symlink or the function
    is not supported. */
GLOBAL (char *_p_ReadLink (const char *FileName UNUSED))
{
  #ifdef HAVE_READLINK
  int Size = 0x20, Res;
  do
    {
      char *Buffer = _p_New (Size *= 2);
      errno = 0;
      Res = readlink (FileName, Buffer, Size);
      if (Res >= 0 && Res < Size)
        {
          Buffer[Res] = 0;
          return Buffer;
        }
      _p_Dispose (Buffer);
    }
  while (Res >= 0);
  #else
  errno = ENOSYS;
  #endif
  return NULL;
}

#if !(defined (HAVE_REALPATH) || defined (realpath))

/* Must not be a macro, because it must evalute its argument only once */
static inline int isslash (char ch)
{
  return ch == '/' || ch == _p_DirSeparatorVar;
}

#define DOSDRIVE(name) (isslash ('\\') && (name)[0] != 0 && (name)[1] == ':')

static char *realpath (char *name, char *resolved_path)
{
  char *dest, *start, *end, *rpath_limit;
  rpath_limit = resolved_path + MAXPATHLEN;
#ifdef __OS_DOS__
  if (DOSDRIVE (name))
    {
      if (isslash (name[2]))
        {
          dest = resolved_path;
          *dest++ = *name++;
          *dest++ = *name++;
          if (*name) *dest++ = '/';
        }
      else
        {
          char tmp[3];
          tmp[0] = *name++;
          tmp[1] = *name++;
          tmp[2] = 0;

          /* @@@@@ FIXME: _fullpath is a private mingw routine, and
             _fixpath a private DJGPP routine (which will not be
             necessary in DJGPP versions after 2.02 because DJGPP
             will have realpath then -- or so they said ...). I
             suppose they don't exist under EMX, but I don't know
             this system. There is probably something equivalent, to
             expand a path like `c:' to `c:\foo\bar', i.e., the
             current directory on some drive (but not necessarily
             the current drive, so we can't use getcwd() ). */
          /*#if (__DJGPP__ == 2) && (__DJGPP_MINOR__ <= 2)*/
          #ifdef __GO32__
          #define _fullpath(resolved_path, path, size) _fixpath (path, resolved_path)
          #endif
          _fullpath (resolved_path, tmp, MAXPATHLEN);

          dest = _p_CStringChPos (resolved_path, '\0');
        }
    }
  else if (isslash (*name) && getcwd (resolved_path, MAXPATHLEN))
    dest = resolved_path + 3;
  else
#endif
       if (!isslash (*name) && getcwd (resolved_path, MAXPATHLEN))
    dest = _p_CStringChPos (resolved_path, '\0');
  else
    {
      dest = resolved_path;
      *dest++ = '/';
    }
  for (start = end = name; *start; start = end)
    {
      while (isslash (*start)) ++start;
      for (end = start; *end && !isslash (*end); ++end);
      if (end == start)
        break;
      else if (strncmp (start, ".", end - start) == 0)
        /* nothing */;
      else if (strncmp (start, "..", end - start) == 0) {
        if (dest > resolved_path + 1 + 2 * DOSDRIVE (resolved_path))
          while (!isslash ((--dest)[-1]));
      } else {
        if (!isslash (dest[-1])) *dest++ = '/';
        if (dest + (end - start) >= rpath_limit) return NULL;
        _p_Move (start, dest, end - start);
        dest += end - start;
      }
    }
  if (dest > resolved_path + 1 + 2 * DOSDRIVE (resolved_path) && isslash (dest[-1])) --dest;
  *dest = '\0';
  return resolved_path;
}
#endif

/** Returns a pointer to a *static* buffer! */
GLOBAL (char *_p_CStringRealPath (char *Path))
{
  /*@@ SuSE Linux's libc has a bug that shows with static buffers */
  static/*!!!*/ char Buf[MAXPATHLEN];
  char TempBuf[MAXPATHLEN], TempBuf2[MAXPATHLEN];
  /*@@ Even worse: libc5 (not only on SuSE) and perhaps other versions
       forget to check the return value of getcwd(), so they behave
       wrong, e.g. if the current directory does not exist. */
  if (*Path != '/' && !getcwd (TempBuf, MAXPATHLEN - 1))
    {
      /* ugly hack ... */
      *TempBuf2 = '/';
      _p_CStringLCopy (TempBuf2 + 1, Path, MAXPATHLEN - 2);
      Path = TempBuf2;
    }
  _p_CStringLCopy (Buf, realpath (Path, TempBuf), MAXPATHLEN - 1);
  return Buf;
}

#define CONVMODE(FROM,TO) ((Mode & FROM) ? TO : 0)

/** File mode constants that are ORed for BindingType.Mode, ChMod,
    CStringChMod and Stat. The values below are valid for all OSs
    (as far as supported). If the OS uses different values, they're
    converted internally. */
enum {
  fm_SetUID           = 04000,
  fm_SetGID           = 02000,
  fm_Sticky           = 01000,
  fm_UserReadable     = 00400,
  fm_UserWritable     = 00200,
  fm_UserExecutable   = 00100,
  fm_GroupReadable    = 00040,
  fm_GroupWritable    = 00020,
  fm_GroupExecutable  = 00010,
  fm_OthersReadable   = 00004,
  fm_OthersWritable   = 00002,
  fm_OthersExecutable = 00001
};

#define ALLMODES (S_ISUID | S_ISGID | S_ISVTX | S_IRUSR | S_IWUSR | S_IXUSR | \
                  S_IRGRP | S_IWGRP | S_IXGRP | S_IROTH | S_IWOTH | S_IXOTH)

/* convert the constants on "strange" OSs */
#if S_ISUID != fm_SetUID         || S_ISGID != fm_SetGID         || S_ISVTX != fm_Sticky          || \
    S_IRUSR != fm_UserReadable   || S_IWUSR != fm_UserWritable   || S_IXUSR != fm_UserExecutable  || \
    S_IRGRP != fm_GroupReadable  || S_IWGRP != fm_GroupWritable  || S_IXGRP != fm_GroupExecutable || \
    S_IROTH != fm_OthersReadable || S_IWOTH != fm_OthersWritable || S_IXOTH != fm_OthersExecutable
static inline int _p_Mode2SysMode (int Mode)
{
  return CONVMODE (fm_SetUID, S_ISUID)
       | CONVMODE (fm_SetGID, S_ISGID)
       | CONVMODE (fm_Sticky, S_ISVTX)
       | CONVMODE (fm_UserReadable, S_IRUSR)
       | CONVMODE (fm_UserWritable, S_IWUSR)
       | CONVMODE (fm_UserExecutable, S_IXUSR)
       | CONVMODE (fm_GroupReadable, S_IRGRP)
       | CONVMODE (fm_GroupWritable, S_IWGRP)
       | CONVMODE (fm_GroupExecutable, S_IXGRP)
       | CONVMODE (fm_OthersReadable, S_IROTH)
       | CONVMODE (fm_OthersWritable, S_IWOTH)
       | CONVMODE (fm_OthersExecutable, S_IXOTH);
}

static inline int _p_SysMode2Mode (int Mode)
{
  return CONVMODE (S_ISUID, fm_SetUID)
       | CONVMODE (S_ISGID, fm_SetGID)
       | CONVMODE (S_ISVTX, fm_Sticky)
       | CONVMODE (S_IRUSR, fm_UserReadable)
       | CONVMODE (S_IWUSR, fm_UserWritable)
       | CONVMODE (S_IXUSR, fm_UserExecutable)
       | CONVMODE (S_IRGRP, fm_GroupReadable)
       | CONVMODE (S_IWGRP, fm_GroupWritable)
       | CONVMODE (S_IXGRP, fm_GroupExecutable)
       | CONVMODE (S_IROTH, fm_OthersReadable)
       | CONVMODE (S_IWOTH, fm_OthersWritable)
       | CONVMODE (S_IXOTH, fm_OthersExecutable);
}
#else
static inline int _p_Mode2SysMode (int Mode)
{
  return Mode & ALLMODES;
}

static inline int _p_SysMode2Mode (int Mode)
{
  return Mode & ALLMODES;
}
#endif

/** Constants for Access and OpenHandle */
enum {
  MODE_EXEC     = 1 << 0,
  MODE_WRITE    = 1 << 1,
  MODE_READ     = 1 << 2,
  MODE_FILE     = 1 << 3,
  MODE_CREATE   = 1 << 4,
  MODE_EXCL     = 1 << 5,
  MODE_TRUNCATE = 1 << 6,
  MODE_APPEND   = 1 << 7,
  MODE_BINARY   = 1 << 8
};

/** Check if a file name is accessible. */
GLOBAL (int _p_Access (const char *FileName, int Request))
{
  int Result = MODE_FILE;
  if ((Request & MODE_FILE)  && access (FileName, F_OK) != 0) return 0;
  if ((Request & MODE_EXEC)  && access (FileName, X_OK) == 0) Result |= MODE_EXEC;
  if ((Request & MODE_WRITE) && access (FileName, W_OK) == 0) Result |= MODE_WRITE;
  if ((Request & MODE_READ)  && access (FileName, R_OK) == 0) Result |= MODE_READ;
  return Result & Request;
}

/** Get information about a file. Any argument except FileName can
    be Null. */
GLOBAL (int _p_Stat (const char *FileName, FileSizeType *Size,
  UnixTimeType *ATime, UnixTimeType *MTime, UnixTimeType *CTime,
  int *User, int *Group, int *Mode, int *Device, int *INode, int *Links,
  Boolean *SymLink, Boolean *Dir, Boolean *Special))
{
  #ifndef HAVE_STAT
  return -2;
  #else
  struct stat st;
  errno = 0;
  if (SymLink)
    {
      if (lstat (FileName, &st) < 0)
        return -1;
      *SymLink = 0;
      if (S_ISLNK (st.st_mode))
        {
          *SymLink = 1;
          stat (FileName, &st);
        }
    }
  else if (stat (FileName, &st) < 0)
    return -1;
  if (Size)    *Size    = (FileSizeType) st.st_size;
  if (ATime)   *ATime   = (UnixTimeType) st.st_atime;
  if (MTime)   *MTime   = (UnixTimeType) st.st_mtime;
  if (CTime)   *CTime   = (UnixTimeType) st.st_ctime;
  if (User)    *User    = st.st_uid;
  if (Group)   *Group   = st.st_gid;
  if (Mode)    *Mode    = _p_SysMode2Mode (st.st_mode);
  if (Device)  *Device  = st.st_dev;
  if (INode)   *INode   = st.st_ino;
  if (Links)   *Links   = st.st_nlink;
  if (Dir)     *Dir     = S_ISDIR (st.st_mode);
  if (Special) *Special = S_ISCHR (st.st_mode) || S_ISBLK (st.st_mode) || S_ISFIFO (st.st_mode) || S_ISSOCK (st.st_mode);
  return 0;
  #endif
}

static int conv_filemode (int Mode)
{
  return CONVMODE (MODE_BINARY, O_BINARY)
       | CONVMODE (MODE_CREATE, O_CREAT)
       | CONVMODE (MODE_EXCL, O_EXCL)
       | CONVMODE (MODE_TRUNCATE, O_TRUNC)
       | CONVMODE (MODE_APPEND, O_APPEND);
}

GLOBAL (int _p_OpenHandle (const char *FileName, int Mode))
{
  errno = 0;
  return open (FileName, ((Mode & MODE_WRITE) ? ((Mode & MODE_READ) ? O_RDWR : O_WRONLY) : O_RDONLY) | conv_filemode (Mode), 0666);
}

GLOBAL (ssize_t _p_ReadHandle (int Handle, void *Buffer, size_t Size))
{
  ssize_t Result;
  errno = 0;
  do
    Result = read (Handle, Buffer, Size > SSIZE_MAX ? SSIZE_MAX : Size);
  while (ISEINTR (Result));
  return Result;
}

GLOBAL (ssize_t _p_WriteHandle (int Handle, void *Buffer, size_t Size))
{
  ssize_t Result;
  errno = 0;
  do
    Result = write (Handle, Buffer, Size > SSIZE_MAX ? SSIZE_MAX : Size);
  while (ISEINTR (Result));
  if (Result < 0 && (errno == EPIPE || errno == ENOSPC)) Result = 0;
  return Result;
}

GLOBAL (int _p_CloseHandle (int Handle))
{
  errno = 0;
  return close (Handle);
}

GLOBAL (void _p_FlushHandle (int Handle UNUSED))
{
  #ifdef HAVE_FSYNC
  fsync (Handle);
  #endif
}

GLOBAL (int _p_DupHandle (int Src UNUSED, int Dest UNUSED))
{
  #ifdef HAVE_DUP2
  return dup2 (Src, Dest);
  #else
  errno = ENOSYS;
  return -1;
  #endif
}

GLOBAL_ATTR (int _p_SetFileMode (int Handle UNUSED, int Mode UNUSED, Boolean On UNUSED), ignorable)
{
  #ifdef HAVE_FCNTL
  if (Handle >= 0)
    {
      int f = fcntl (Handle, F_GETFL);
      if (f < 0)
        return f;
      Mode = conv_filemode (Mode);
      return fcntl (Handle, F_SETFL, On ? (f | Mode) : (f & ~Mode));
    }
  #endif
  errno = ENOSYS;
  return False;
}

GLOBAL (int _p_CStringRename (const char *OldName UNUSED, const char *NewName UNUSED))
{
  #ifdef HAVE_RENAME
  errno = 0;
  return rename (OldName, NewName);
  #else
  errno = ENOSYS;
  return -1;
  #endif
}

GLOBAL (int _p_CStringUnlink (const char *FileName UNUSED))
{
  #ifdef HAVE_UNLINK
  errno = 0;
  return unlink (FileName);
  #else
  errno = ENOSYS;
  return -1;
  #endif
}

GLOBAL (int _p_CStringChDir (const char *FileName UNUSED))
{
  #ifdef HAVE_CHDIR
  errno = 0;
  return chdir (FileName);
  #else
  errno = ENOSYS;
  return -1;
  #endif
}

GLOBAL (int _p_CStringMkDir (const char *FileName UNUSED))
{
  #ifdef HAVE_MKDIR
  errno = 0;
  #ifdef MKDIR_TWOARG
  return mkdir (FileName, 0777);
  #else
  return mkdir (FileName);
  #endif
  #else
  errno = ENOSYS;
  return -1;
  #endif
}

GLOBAL (int _p_CStringRmDir (const char *FileName UNUSED))
{
  #ifdef HAVE_RMDIR
  errno = 0;
  return rmdir (FileName);
  #else
  errno = ENOSYS;
  return -1;
  #endif
}

GLOBAL_ATTR (int _p_UMask (int Mask UNUSED), ignorable)
{
  #ifdef HAVE_UMASK
  int i;
  errno = 0;
  i = umask (_p_Mode2SysMode (Mask));
  return i < 0 ? i : _p_SysMode2Mode (i);
  #else
  errno = ENOSYS;
  return -1;
  #endif
}

GLOBAL (int _p_CStringChMod (const char *FileName UNUSED, int Mode UNUSED))
{
  #ifdef HAVE_CHMOD
  errno = 0;
  return chmod (FileName, _p_Mode2SysMode (Mode));
  #else
  errno = ENOSYS;
  return -1;
  #endif
}

GLOBAL (int _p_CStringChOwn (const char *FileName UNUSED, int Owner UNUSED, int Group UNUSED))
{
  #ifdef HAVE_CHOWN
  errno = 0;
  return chown (FileName, Owner, Group);
  #else
  errno = ENOSYS;
  return -1;
  #endif
}

GLOBAL (int _p_CStringUTime (const char *FileName UNUSED, UnixTimeType AccessTime UNUSED, UnixTimeType ModificationTime UNUSED))
{
  #ifdef HAVE_UTIME
  struct utimbuf utim;
  utim.actime = (time_t) AccessTime;
  utim.modtime = (time_t) ModificationTime;
  errno = 0;
  return utime (FileName, &utim);
  #else
  errno = ENOSYS;
  return -1;
  #endif
}

/** Constants for SeekHandle */
enum {
  SeekAbsolute = 0,
  SeekRelative = 1,
  SeekFileEnd  = 2
};

/** Seek to a position on a file handle. */
GLOBAL (FileSizeType _p_SeekHandle (int Handle UNUSED, FileSizeType Offset UNUSED, int Whence))
{
  int CWhence;
  CWhence = (Whence == SeekRelative) ? SEEK_CUR : (Whence == SeekFileEnd) ? SEEK_END : SEEK_SET;
  errno = 0;
  #ifdef HAVE_LSEEK64
  return lseek64 (Handle, Offset, CWhence);
  #elif defined (HAVE_LLSEEK)
  {
    FileSizeType Result = llseek (Handle, Offset, CWhence);
    if (Result >= 0) return Result;
  }
  #endif
  #ifdef HAVE_LSEEK
  if ((off_t) Offset != Offset)
    {
      errno = EFBIG;
      return -1;
    }
  return lseek (Handle, Offset, CWhence);
  #else
  errno = ENOSYS;
  return -1;
  #endif
}

GLOBAL (int _p_TruncateHandle (int Handle UNUSED, FileSizeType Size UNUSED))
{
  errno = 0;
  #ifdef HAVE_FTRUNCATE64
  {
    int Result = ftruncate64 (Handle, Size);
    if (Result >= 0) return Result;
  }
  #endif
  #ifdef HAVE_FTRUNCATE
  if ((off_t) Size != Size)
    {
      errno = EFBIG;
      return -1;
    }
  return ftruncate (Handle, Size);
  #else
  errno = ENOSYS;
  return -1;
  #endif
}

GLOBAL (Boolean _p_LockHandle (int Handle UNUSED, Boolean WriteLock UNUSED, Boolean Block UNUSED))
{
  #ifdef HAVE_FCNTL
  if (Handle >= 0)
    {
      struct flock Lock;
      errno = 0;
      memset (&Lock, 0, sizeof (Lock));
      Lock.l_type = WriteLock ? F_WRLCK : F_RDLCK;
      Lock.l_whence = SEEK_SET;
      Lock.l_start = Lock.l_len = 0;
      return fcntl (Handle, Block ? F_SETLKW : F_SETLK, &Lock) == 0;
    }
  #endif
  errno = ENOSYS;
  return False;
}

GLOBAL (Boolean _p_UnlockHandle (int Handle UNUSED))
{
  #ifdef HAVE_FCNTL
  if (Handle >= 0)
    {
      struct flock Lock;
      errno = 0;
      memset (&Lock, 0, sizeof (Lock));
      Lock.l_type = F_UNLCK;
      Lock.l_whence = SEEK_SET;
      Lock.l_start = Lock.l_len = 0;
      return fcntl (Handle, F_SETLK, &Lock) == 0;
    }
  #endif
  errno = ENOSYS;
  return False;
}

GLOBAL (int _p_SelectHandle (int Count, InternalSelectType *Events, MicroSecondTimeType MicroSeconds))
{
  int i;
  #ifndef HAVE_SELECT
  for (i = 0; i < Count; i++)
    if (Events[i].Handle >= 0)
      return -1;
  _p_SleepMicroSeconds (MicroSeconds);
  return 0;
  #else
  int Result, n = 0, fn;
  fd_set readfds, writefds, exceptfds;
  struct timeval timeout, *ptimeout;
  if (MicroSeconds < 0)
    ptimeout = NULL;
  else
    {
      timeout.tv_sec  = MicroSeconds / 1000000;
      timeout.tv_usec = MicroSeconds % 1000000;
      ptimeout = &timeout;
    }
  if (!Events || Count <= 0)
    return select (0, NULL, NULL, NULL, ptimeout);
  FD_ZERO (&readfds);
  FD_ZERO (&writefds);
  FD_ZERO (&exceptfds);
  for (i = 0; i < Count; i++)
    if ((fn = Events[i].Handle) >= 0)
      {
        if (fn >= n) n = fn + 1;
        if (Events[i].Read) FD_SET (fn, &readfds);
        if (Events[i].Write) FD_SET (fn, &writefds);
        if (Events[i].Exception) FD_SET (fn, &exceptfds);
      }
  Result = select (n, &readfds, &writefds, &exceptfds, ptimeout);
  for (i = 0; i < Count; i++)
    if ((fn = Events[i].Handle) >= 0)
      {
        Events[i].Read = FD_ISSET (fn, &readfds) != 0;
        Events[i].Write = FD_ISSET (fn, &writefds) != 0;
        Events[i].Exception = FD_ISSET (fn, &exceptfds) != 0;
      }
  return Result;
  #endif
}

/** Constants for MMapHandle and MemoryMap */
enum {
  mm_Readable   = 1,
  mm_Writable   = 2,
  mm_Executable = 4
};

/** Try to map (a part of) a file to memory. */
GLOBAL (void *_p_MMapHandle (void *Start UNUSED, size_t Length UNUSED, int Access UNUSED, Boolean Shared UNUSED, int Handle UNUSED, FileSizeType Offset UNUSED))
{
  #ifdef HAVE_MMAP
  void *Result;
  errno = 0;
  Result = (Handle < 0) ? NULL : mmap (Start, Length,
            ((Access & mm_Readable) ? PROT_READ : 0) |
            ((Access & mm_Writable) ? PROT_WRITE : 0) |
            ((Access & mm_Executable) ? PROT_EXEC : 0),
            Shared ? MAP_SHARED : MAP_FIXED, Handle, Offset);
  if (Result == (void *) MAP_FAILED) Result = NULL;
  return Result;
  #else
  errno = ENOSYS;
  return NULL;
  #endif
}

/** Unmap a previous memory mapping. */
GLOBAL (int _p_MUnMapHandle (void *Start UNUSED, size_t Length UNUSED))
{
  #ifdef HAVE_MUNMAP
  errno = 0;
  return munmap (Start, Length);
  #else
  errno = ENOSYS;
  return -1;
  #endif
}

/** Returns the file name of the terminal device that is open on
    Handle. Returns nil if (and only if) Handle is not open or not
    connected to a terminal. If NeedName is False, it doesn't bother
    to search for the real name and just returns DefaultName if it
    is a terminal and nil otherwise. DefaultName is also returned if
    NeedName is True, Handle is connected to a terminal, but the
    system does not provide information about the real file name. */
GLOBAL (char *_p_GetTerminalNameHandle (int Handle, Boolean NeedName, char *DefaultName))
{
  /* Checking isatty() first is often much more efficient.
     Furthermore, ttyname() on some systems, e.g. Linux libc-5, does
     not reliably return NULL when not connected to a terminal. It
     might seem strange to export the functionality of isatty() and
     ttyname() through this single function, and then again through
     two Pascal functions (IsTerminal and GetTerminalName), but
     since one or both of isatty() and ttyname() may be missing on
     any system, this does in fact seem to be a good way. */
  char *s;
  int istty;
  if (Handle < 0) return NULL;
  #ifdef HAVE_ISATTY
  if ((istty = isatty (Handle)) == 0) return NULL;
  if (istty > 0 && !NeedName) return DefaultName;
  #else
  istty = -1;
  #endif
  #ifdef HAVE_TTYNAME
  s = ttyname (Handle);
  #else
  s = NULL;
  #endif
  return (istty > 0 && (!s || !*s)) ? DefaultName : s;
}

/** System routines */

/** Sets the process group of Process (or the current one if Process
    is 0) to ProcessGroup (or its PID if ProcessGroup is 0). Returns
    True if successful. */
GLOBAL (Boolean _p_SetProcessGroup (int Process UNUSED, int ProcessGroup UNUSED))
{
  #ifdef HAVE_SETPGID
  return setpgid (Process, ProcessGroup) == 0;
  #else
  return False;
  #endif
}

/** Sets the process group of a terminal given by Terminal (as a file
    handle) to ProcessGroup. ProcessGroup must be the ID of a process
    group in the same session. Returns True if successful. */
GLOBAL (Boolean _p_SetTerminalProcessGroup (int Handle UNUSED, int ProcessGroup UNUSED))
{
  #ifdef HAVE_TCSETPGRP
  errno = 0;
  return tcsetpgrp (Handle, ProcessGroup) == 0;
  #else
  errno = ENOSYS;
  return False;
  #endif
}

/** Returns the process group of a terminal given by Terminal (as a
    file handle), or -1 on error. */
GLOBAL (int _p_GetTerminalProcessGroup (int Handle UNUSED))
{
  #ifdef HAVE_TCGETPGRP
  errno = 0;
  return tcgetpgrp (Handle);
  #else
  errno = ENOSYS;
  return -1;
  #endif
}

#ifdef HAVE_INPUT_SIGNALS
static Boolean _p_OldTermiosSet = False;
static struct termios _p_OldTermios;

static void _p_InputSignalsAtExit ()
{
  if (_p_OldTermiosSet)
    tcsetattr (0, TCSANOW, &_p_OldTermios);
}
#endif

static Boolean _p_LastInputSignals = True;

/** Set the standard input's signal generation, if it is a terminal. */
GLOBAL (void _p_SetInputSignals (Boolean Signals UNUSED))
{
  #ifdef HAVE_INPUT_SIGNALS
  struct termios new_termios;
  _p_LastInputSignals = Signals;
  if (tcgetattr (0, &new_termios))
    return;
  if (!_p_OldTermiosSet)
    {
      _p_OldTermios = new_termios;
      _p_OldTermiosSet = 1;
      _p_AtExit (_p_InputSignalsAtExit);
    }
  if (Signals)
    new_termios.c_lflag |= ISIG;
  else
    new_termios.c_lflag &= ~ISIG;
  tcsetattr (0, TCSANOW, &new_termios);
  #endif
}

/** Get the standard input's signal generation, if it is a terminal. */
GLOBAL (Boolean _p_GetInputSignals (void))
{
  #ifdef HAVE_INPUT_SIGNALS
  struct termios current_termios;
  if (tcgetattr (0, &current_termios) == 0)
    return (current_termios.c_lflag & ISIG) != 0;
  #endif
  return _p_LastInputSignals;
}

/** Internal routines */

/** Returns system information if available. Fields not available will
    be set to nil. */
GLOBAL (void _p_CStringSystemInfo (char **SysName, char **NodeName, char **Release, char **Version, char **Machine, char **DomainName))
{
  #ifdef HAVE_UNAME
  static struct utsname Buf;
  if (!uname (&Buf))
    {
      *SysName    = Buf.sysname;
      *NodeName   = Buf.nodename;
      *Release    = Buf.release;
      *Version    = Buf.version;
      *Machine    = Buf.machine;
      #if HAVE_DomainName
      *DomainName = Buf.domainname;
      #else
      *DomainName = NULL;
      #endif
      return;
    }
  #endif
  *SysName = *NodeName = *Release = *Version = *Machine = *DomainName = NULL;
}

/** Returns the path of the running executable *if possible*. */
GLOBAL (const char *_p_CStringExecutablePath (char *Buffer UNUSED))
{
  #if defined (HAVE_EXECUTABLE_PATH) || defined (executable_path)
  char *Result = executable_path (Buffer);
  if (Result) return Result;
  #endif
  return _p_CParameters[0];
}

/*@internal*/

/** Returns a temporary directory name *if possible*. */
GLOBAL (const char *_p_CStringGetTempDirectory (char *Buffer UNUSED, int Size UNUSED))
{
  #ifdef HAVE_GETTMPDIR
  return gettmpdir (Buffer, Size);
  #endif
  return NULL;
}

/** Executes a command line. */
GLOBAL (int _p_CSystem (char *CmdLine))
{
  int r;
  errno = 0;
  r = system (CmdLine);
  return errno ? -1 : r;
}

GLOBAL (PCStrings _p_GetStartEnvironment (PCStrings ValueIfNotFound UNUSED))
{
  #if defined (HAVE_ENVIRON) || defined (environ)
  return environ;
  #else
  return ValueIfNotFound;
  #endif
}

/* The environment handling of the different libcs is a whole big mess:
   - The environment passed to main() may or may not survive putenv() calls
     (e.g., not under DJGPP). It does not even contain a meaningful value
     on some systems (e.g., mingw).
   - There may or may not be an environ or __environ variable containing
     the current environment.
   - If it exists, assignments to it can cause segfaults (e.g., glibc).
   - The putenv() function (POSIX) expects a non-temporary string,
     so the caller has to make a copy, but libc does not free it
     when the variable is unset or overwritten.
   - OTOH, there's no guarantee if and when the caller may free the string
     after it's not needed any more.
   - Functions like execl() or system() access the (internal) current
     environment. Furthermore, system() is quite system specific (esp.
     on Unix vs. Dos systems), so it can't be easily reprogrammed using
     another environment.
   This function tries to make the best of the situation, so don't
   be surprised that it's a whole big mess as well. */
GLOBAL (void _p_CStringSetEnv (char *VarName UNUSED, char *Value UNUSED, char *NewEnvCString UNUSED, Boolean UnSet UNUSED))
{
  #ifdef HAVE_UNSETENV
  if (UnSet)
    {
      unsetenv (VarName);
      return;
    }
  #endif
  #ifdef HAVE_SETENV
  setenv (VarName, Value, 1);
  #elif defined (HAVE_PUTENV)
  {
    #ifdef HAVE_GETENV
    char *OldValue = getenv (VarName);
    if ((!OldValue && !UnSet) || _p_CStringComp (Value, OldValue) != 0)
    #endif
      {
        int n = _p_CStringLength (NewEnvCString) + 1;
        char *s = _p_InternalNew (n);
        _p_Move (NewEnvCString, s, n);
        putenv (s);
      }
  }
  #endif
}

/*@endinternal*/

/** Sets ErrNo to the value of `errno' and returns the description
    for this error. May return nil if not supported! ErrNo may be
    Null (then only the description is returned). */
GLOBAL (const char *_p_CStringStrError (int *ErrNo))
{
  if (ErrNo) *ErrNo = errno;
  if (errno == 0) return NULL;
  if (errno >= START_EMULATED_ERRNOS)
    switch (errno)
      {
        case ENOSYS: return "Function not implemented";
        case EFBIG:  return "File position too large";
      }
  #if defined (HAVE_STRERROR) || defined (strerror)
  if (errno >= 0)
    return strerror (errno);
  #endif
  return NULL;
}

/*@internal*/

/** Returns a description for a signal. May return nil if not supported! */
GLOBAL (const char *_p_CStringStrSignal (int Signal UNUSED))
{
  if (Signal >= 0
      #ifdef SIGMAX
      && Signal <= SIGMAX
      #endif
     )
  #if defined (HAVE_STRSIGNAL) || defined (strsignal)
    return strsignal (Signal);
  #elif defined (HAVE_SYS_SIGLIST) || defined (sys_siglist)
    return sys_siglist[Signal];
  #else
    ;
  #endif
  return NULL;
}

GLOBAL (int _p_FNMatch (const char *Pattern UNUSED, const char *FileName UNUSED))
{
  #ifdef HAVE_FNMATCH
  errno = 0;
  return fnmatch (Pattern, FileName, FNM_PATHNAME | FNM_PERIOD);
  #else
  errno = ENOSYS;
  return -1;
  #endif
}

GLOBAL (void _p_GlobInternal (GlobBuffer *Buf, char *Pattern UNUSED))
{
  #ifdef HAVE_GLOB
  int first = Buf->Internal2 == NULL;
  if (!Buf->Internal1)
    {
      Buf->Internal1 = _p_New (sizeof (glob_t));
      Buf->Internal3 = 0;
    }
  if (glob (Pattern, GLOB_MARK | (first ? 0 : GLOB_APPEND), NULL, (glob_t *) Buf->Internal1) != 0 && first)
    {
      _p_Dispose (Buf->Internal1);
      Buf->Internal1 = NULL;
      Buf->Internal2 = NULL;
      Buf->Internal3 = 0;
    }
  else
    {
      Buf->Internal2 = ((glob_t *) Buf->Internal1)->gl_pathv;
      Buf->Internal3 = ((glob_t *) Buf->Internal1)->gl_pathc;
    }
  #else
  Buf->Internal3 = 0;
  #endif
}

GLOBAL (void _p_GlobFreeInternal (GlobBuffer *Buf UNUSED))
{
  #ifdef HAVE_GLOB
  if (Buf->Internal1)
    {
      globfree ((glob_t *) Buf->Internal1);
      _p_Dispose (Buf->Internal1);
    }
  #endif
}

#if defined (HAVE_GETPWNAM) || defined (HAVE_GETPWUID) || defined (HAVE_GETPWENT)
static void _p_PWL2C (const struct passwd *p, TCPasswordEntry *Entry)
{
  Entry->UserName = _p_CStringNew (p->pw_name);
  #ifdef HAVE_PW_GECOS
  Entry->RealName = _p_CStringNew (p->pw_gecos);
  #else
  Entry->RealName = NULL;
  #endif
  #ifdef HAVE_PW_PASSWD
  Entry->Password = _p_CStringNew (p->pw_passwd);
  #else
  Entry->Password = NULL;
  #endif
  Entry->HomeDirectory = _p_CStringNew (p->pw_dir);
  Entry->Shell = _p_CStringNew (p->pw_shell);
  Entry->UID = p->pw_uid;
  Entry->GID = p->pw_gid;
}
#endif

GLOBAL (Boolean _p_CGetPwNam (char *UserName UNUSED, TCPasswordEntry *Entry UNUSED))
{
  #ifdef HAVE_GETPWNAM
  struct passwd *p = getpwnam (UserName);
  if (!p) return False;
  _p_PWL2C (p, Entry);
  return True;
  #else
  return False;
  #endif
}

GLOBAL (Boolean _p_CGetPwUID (int UID UNUSED, TCPasswordEntry *Entry UNUSED))
{
  #ifdef HAVE_GETPWUID
  struct passwd *p = getpwuid (UID);
  if (!p) return False;
  _p_PWL2C (p, Entry);
  return True;
  #else
  return False;
  #endif
}

GLOBAL (int _p_CGetPwEnt (PCPasswordEntries *Entries UNUSED))
{
  int Count = 0;
  #if defined (HAVE_GETPWENT) && defined (HAVE_SETPWENT) && defined (HAVE_ENDPWENT)
  struct passwd *p;
  setpwent ();
  *Entries = NULL;
  do
    {
      p = getpwent ();
      if (!p) break;
      _p_ReAllocMem ((void **) Entries, (++Count) * sizeof (TCPasswordEntry));
      _p_PWL2C (p, &((*Entries)[Count - 1]));
    }
  while (1);
  endpwent ();
  #endif
  return Count;
}

GLOBAL (void _p_InitMisc (void))
{
  #ifdef HAVE_SETLOCALE
  #ifdef LC_COLLATE
  setlocale (LC_COLLATE, "");
  #endif
  #ifdef LC_CTYPE
  setlocale (LC_CTYPE, "");
  #endif
  #ifdef LC_MONETARY
  setlocale (LC_MONETARY, "");
  #endif
  #ifdef LC_TIME
  setlocale (LC_TIME, "");
  #endif
  #ifdef LC_MESSAGES
  setlocale (LC_MESSAGES, "");
  #endif
  #endif
}

GLOBAL (void _p_InitMalloc (void (*WarnProc) (char *Msg) UNUSED))
{
  #ifdef HAVE_MALLOC_INIT
  malloc_init (0, WarnProc);
  #endif
}

GLOBAL_ATTR (void _p_ExitProgram (int Status, Boolean AbortFlag UNUSED), noreturn)
{
  #ifdef HAVE_ABORT
  if (AbortFlag) abort ();
  #endif
  exit (Status);
}

/*@endinternal*/
