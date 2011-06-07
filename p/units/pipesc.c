/*Support routines for pipes.pas

  Copyright (C) 1998-2006 Free Software Foundation, Inc.

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
  General Public License. */

#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>

#define GLOBAL(decl) decl; decl

#ifdef __MINGW32__
#define SPAWN_ARG_CONST const
#else
#define SPAWN_ARG_CONST
#endif

/* Keep this consistent with the one in pipes.pas */
#if !(defined (MSDOS) || defined (__MINGW32__))

#include <errno.h>

GLOBAL (int _p_CPipe (char *path, char *argv[], char *envp[], int *pipe_stdin, int *pipe_stdout, int *pipe_stderr, void (*ChildProc) ()))
{
  int executable = *path && access (path, X_OK) == 0, fd_stdout[2], fd_stderr[2], fd_stdin[2];
  pid_t pid;
  errno = 0;
  if (*path && !executable)
    return -2;
  if (   (pipe_stdout && pipe (fd_stdout))
      || (pipe_stderr && pipe_stderr != pipe_stdout && pipe (fd_stderr))
      || (pipe_stdin  && pipe (fd_stdin)))
    return -3;
  pid = fork ();
  if (pid < 0)
    return -4;
  if (pid)
    {
      if (pipe_stdout)
        {
          close (fd_stdout[1]);
          *pipe_stdout = fd_stdout[0];
        }
      if (pipe_stderr && pipe_stderr != pipe_stdout)
        {
          close (fd_stderr[1]);
          *pipe_stderr = fd_stderr[0];
        }
      if (pipe_stdin)
        {
          close (fd_stdin[0]);
          *pipe_stdin = fd_stdin[1];
        }
      return pid;
    }
  else
    {
      if (pipe_stdout)
        {
          dup2  (fd_stdout[1], 1);
          close (fd_stdout[0]);
          close (fd_stdout[1]);
        }
      if (pipe_stderr)
        {
          if (pipe_stderr == pipe_stdout)
            dup2 (1, 2);
          else
            {
              dup2  (fd_stderr[1], 2);
              close (fd_stderr[0]);
              close (fd_stderr[1]);
            }
        }
      if (pipe_stdin)
        {
          dup2  (fd_stdin[0], 0);
          close (fd_stdin[0]);
          close (fd_stdin[1]);
        }
      if (ChildProc) ChildProc ();
      if (executable)
        {
          execve (path, argv, envp);
          fprintf (stderr, "cannot execute %s\n", path);
          _exit (127);
        }
      else
        _exit (0);
      return -5;
    }
}

#else

#include <fcntl.h>
#include <process.h>

GLOBAL (int _p_CPipe (char *path, SPAWN_ARG_CONST char *argv[], SPAWN_ARG_CONST char *envp[], char *name_stdin, char *name_stdout, char *name_stderr, void (*ChildProc) ()))
{
  int executable = *path && !access (path, X_OK), save_stdin = -1, save_stdout = -1, save_stderr = -1, h, r;
  if (*path && !executable)
    return -2;
  if (name_stdin)
    {
      save_stdin = dup (0);
      h = open (name_stdin, O_RDONLY, 0777);
      dup2 (h, 0);
      close (h);
    }
  if (name_stdout)
    {
      save_stdout = dup (1);
      h = open (name_stdout, O_WRONLY | O_CREAT, 0777);
      dup2 (h, 1);
      close (h);
    }
  if (name_stderr)
    {
      save_stderr = dup (2);
      if (name_stderr != name_stdout)
        {
          h = open (name_stderr, O_WRONLY | O_CREAT, 0777);
          dup2 (h, 2);
          close (h);
        }
      else
        dup2 (1, 2);
    }
  if (ChildProc) ChildProc ();
  if (executable)
    r = spawnve (P_WAIT, path, argv, envp);
  else
    r = 0;
  if (name_stdin)
    {
      dup2 (save_stdin, 0);
      close (save_stdin);
    }
  if (name_stdout)
    {
      dup2 (save_stdout, 1);
      close (save_stdout);
    }
  if (name_stderr)
    {
      dup2 (save_stderr, 2);
      close (save_stderr);
    }
  return r;
}

#endif

/* The following comes from pexecute.c */

/* Utilities to execute a program in a subprocess (possibly linked by
   pipes with other subprocesses), and wait for it.
   Copyright (C) 1996, 1997, 1998 Free Software Foundation, Inc.

This file is part of the libiberty library.
Libiberty is free software; you can redistribute it and/or
modify it under the terms of the GNU Library General Public
License as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.

Libiberty is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Library General Public License for more details.

You should have received a copy of the GNU Library General Public
License along with libiberty; see the file COPYING.LIB. If not,
write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA. */

/* This file exports two functions: pexecute and pwait. */

/* This file lives in at least three places: libiberty and gcc and gpc.
   Don't change one without the other. */

#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

/* Flag arguments to pexecute. */
#define PEXECUTE_FIRST   1
#define PEXECUTE_LAST    2
#define PEXECUTE_ONE     (PEXECUTE_FIRST + PEXECUTE_LAST)
#define PEXECUTE_SEARCH  4
#define PEXECUTE_VERBOSE 8


/* pexecute: execute a program.

   PROGRAM and ARGV are the arguments to execv/execvp.

   THIS_PNAME is name of the calling program (i.e. argv[0]).

   TEMP_BASE is the path name, sans suffix, of a temporary file to use
   if needed.  This is currently only needed for MSDOS ports that don't use
   GO32 (do any still exist?).  Ports that don't need it can pass NULL.

   (FLAGS & PEXECUTE_SEARCH) is non-zero if $PATH should be searched
   (??? It's not clear that GCC passes this flag correctly).
   (FLAGS & PEXECUTE_FIRST) is nonzero for the first process in chain.
   (FLAGS & PEXECUTE_LAST) is nonzero for the last process in chain.
   FIRST_LAST could be simplified to only mark the last of a chain of processes
   but that requires the caller to always mark the last one (and not give up
   early if some error occurs).  It's more robust to require the caller to
   mark both ends of the chain.

   The result is the pid on systems like Unix where we fork/exec and on systems
   like WIN32 and OS2 where we use spawn.  It is up to the caller to wait for
   the child.

   The result is the WEXITSTATUS on systems like MSDOS where we spawn and wait
   for the child here.

   Upon failure, ERRMSG_FMT and ERRMSG_ARG are set to the text of the error
   message with an optional argument (if not needed, ERRMSG_ARG is set to
   NULL), and -1 is returned.  `errno' is available to the caller to use.

   pwait: cover function for wait.

   PID is the process id of the task to wait for.
   STATUS is the `status' argument to wait.
   FLAGS is currently unused (allows future enhancement without breaking
   upward compatibility).  Pass 0 for now.

   The result is the pid of the child reaped,
   or -1 for failure (errno says why).

   On systems that don't support waiting for a particular child, PID is
   ignored.  On systems like MSDOS that don't really multitask pwait
   is just a mechanism to provide a consistent interface for the caller.
*/

extern int pwait (int, int *, int);
extern int pexecute (const char *, char * const *, const char *,
                     const char *, const char **, const char **, int);

extern void *_p_New (size_t);
extern void _p_Dispose (void *);
extern char *_p_CStringLCopy (char *, const char *, size_t);
extern char *_p_CStringChPos (const char *, char);
extern int system (const char *);

#define UNUSED __attribute__ ((__unused__))

#ifndef HAVE_VFORK
#define vfork fork
#endif

/* stdin file number. */
#define STDIN_FILE_NO 0

/* stdout file number. */
#define STDOUT_FILE_NO 1

/* value of `pipe': port index for reading. */
#define READ_PORT 0

/* value of `pipe': port index for writing. */
#define WRITE_PORT 1

static const char *install_error_msg = "installation problem, cannot exec `%s'";

#ifdef __MSDOS__

/* MSDOS doesn't multitask, but for the sake of a consistent interface
   the code behaves like it does.  pexecute runs the program, tucks the
   exit code away, and returns a "pid".  pwait must be called to fetch the
   exit code. */

#include <process.h>

/* For communicating information from pexecute to pwait. */
static int last_pid = 0;
static int last_status = 0;
static int last_reaped = 0;

int
pexecute (program, argv, this_pname, temp_base, errmsg_fmt, errmsg_arg, flags)
     const char *program;
     char * const *argv;
     const char *this_pname UNUSED;
     const char *temp_base UNUSED;
     const char **errmsg_fmt, **errmsg_arg;
     int flags;
{
  int rc;

  last_pid++;
  if (last_pid < 0)
    last_pid = 1;

  if ((flags & PEXECUTE_ONE) != PEXECUTE_ONE)
    abort ();

#ifdef __GO32__
  /* ??? What are the possible return values from spawnv? */
  rc = (flags & PEXECUTE_SEARCH ? spawnvp : spawnv) (1, program, argv);
#else
  char *scmd, *rf;
  FILE *argfile;
  int i, el = flags & PEXECUTE_SEARCH ? 4 : 0;

  scmd = (char *) _p_New (strlen (program) + strlen (temp_base) + 6 + el);
  rf = scmd + strlen(program) + 2 + el;
  sprintf (scmd, "%s%s @%s.gp", program,
           (flags & PEXECUTE_SEARCH ? ".exe" : ""), temp_base);
  argfile = fopen (rf, "w");
  if (argfile == 0)
    {
      int errno_save = errno;
      _p_Dispose (scmd);
      errno = errno_save;
      *errmsg_fmt = "cannot open `%s.gp'";
      *errmsg_arg = temp_base;
      return -1;
    }

  for (i=1; argv[i]; i++)
    {
      char *cp;
      for (cp = argv[i]; *cp; cp++)
        {
          if (*cp == '"' || *cp == '\'' || *cp == '\\' || isspace (*cp))
            fputc ('\\', argfile);
          fputc (*cp, argfile);
        }
      fputc ('\n', argfile);
    }
  fclose (argfile);

  rc = system (scmd);

  {
    int errno_save = errno;
    remove (rf);
    _p_Dispose (scmd);
    errno = errno_save;
  }
#endif

  if (rc == -1)
    {
      *errmsg_fmt = install_error_msg;
      *errmsg_arg = (char *) program;
      return -1;
    }

  /* Tuck the status away for pwait, and return a "pid". */
  last_status = rc << 8;
  return last_pid;
}

int
pwait (pid, status, flags)
     int pid;
     int *status;
     int flags UNUSED;
{
  /* On MSDOS each pexecute must be followed by it's associated pwait. */
  if (pid != last_pid
      /* Called twice for the same child? */
      || pid == last_reaped)
    {
      /* ??? ECHILD would be a better choice.  Can we use it here? */
      errno = EINVAL;
      return -1;
    }
  /* ??? Here's an opportunity to canonicalize the values in STATUS.
     Needed? */
  *status = last_status;
  last_reaped = last_pid;
  return last_pid;
}

#endif /* MSDOS */

#if defined (_WIN32)

#include <process.h>
#include <signal.h>
extern int _spawnv ();
extern int _spawnvp ();

#if defined (__CYGWIN__) || defined (__MSYS__)

#define fix_argv(argvec) (argvec)

#else

/* This is a kludge to get around the Microsoft C spawn functions' propensity
   to remove the outermost set of double quotes from all arguments. */

static SPAWN_ARG_CONST char * const *fix_argv (char **argvec);
static SPAWN_ARG_CONST char * const *
fix_argv (argvec)
     char **argvec;
{
  int i;

  for (i = 1; argvec[i] != 0; i++)
    {
      int len, j;
      char *temp, *newtemp;

      temp = argvec[i];
      len = strlen (temp);
      for (j = 0; j < len; j++)
        {
          if (temp[j] == '"' && (newtemp = (char *) malloc (len + 2)))
            {
              _p_CStringLCopy (newtemp, temp, j);
              newtemp [j] = '\\';
              _p_CStringLCopy (&newtemp [j+1], &temp [j], len-j);
              newtemp [len+1] = 0;
              temp = newtemp;
              len++;
              j++;
            }
        }

        argvec[i] = temp;
      }

  return (SPAWN_ARG_CONST char * const *) argvec;
}

#endif /* ! defined (__CYGWIN__) */

int
pexecute (program, argv, this_pname, temp_base, errmsg_fmt, errmsg_arg, flags)
     const char *program;
     char * const *argv;
     const char *this_pname;
     const char *temp_base;
     const char **errmsg_fmt;
     const char **errmsg_arg;
     int flags;
{
  int pid;

  if ((flags & PEXECUTE_ONE) != PEXECUTE_ONE)
    abort ();
  pid = (flags & PEXECUTE_SEARCH ? _spawnvp : _spawnv)
    (_P_NOWAIT, program, fix_argv ((char **) argv));
  if (pid == -1)
    {
      *errmsg_fmt = install_error_msg;
      *errmsg_arg = program;
      return -1;
    }
  return pid;
}

int
pwait (pid, status, flags)
     int pid;
     int *status;
     int flags;
{
  int termstat;

  pid = cwait (&termstat, pid, WAIT_CHILD);

  /* ??? Here's an opportunity to canonicalize the values in STATUS.
     Needed? */

  /* cwait returns the child process exit code in termstat.
     A value of 3 indicates that the child caught a signal, but not
     which one.  Since only SIGABRT, SIGFPE and SIGINT do anything, we
     report SIGABRT. */
  if (termstat == 3)
    *status = SIGABRT;
  else
    *status = (((termstat) & 0xff) << 8);

  return pid;
}

#endif /* _WIN32 */

#ifdef OS2

#include <sys/wait.h>

/* ??? Does OS2 have process.h? */
extern int spawnv ();
extern int spawnvp ();

int
pexecute (program, argv, this_pname, temp_base, errmsg_fmt, errmsg_arg, flags)
     const char *program;
     char * const *argv;
     const char *this_pname;
     const char *temp_base;
     const char **errmsg_fmt, **errmsg_arg;
     int flags;
{
  int pid;

  if ((flags & PEXECUTE_ONE) != PEXECUTE_ONE)
    abort ();
  /* ??? Presumably 1 == _P_NOWAIT. */
  pid = (flags & PEXECUTE_SEARCH ? spawnvp : spawnv) (1, program, argv);
  if (pid == -1)
    {
      *errmsg_fmt = install_error_msg;
      *errmsg_arg = program;
      return -1;
    }
  return pid;
}

int
pwait (pid, status, flags)
     int pid;
     int *status;
     int flags;
{
  /* ??? Here's an opportunity to canonicalize the values in STATUS.
     Needed? */
  int pid = wait (status);
  return pid;
}

#endif /* OS2 */

/* include for Unix-like environments but not for Dos-like environments */
#if ! defined (__MSDOS__) && ! defined (OS2) && ! defined (MPW) \
    && ! defined (_WIN32)

#ifdef VMS
#define vfork() (decc$$alloc_vfork_blocks() >= 0 ? \
               lib$get_current_invo_context(decc$$get_vfork_jmpbuf()) : -1)
#endif

#include <sys/wait.h>

extern int execv ();
extern int execvp ();

int
pexecute (program, argv, this_pname, temp_base, errmsg_fmt, errmsg_arg, flags)
     const char *program;
     char * const *argv;
     const char *this_pname;
     const char *temp_base UNUSED;
     const char **errmsg_fmt, **errmsg_arg;
     int flags;
{
  int (*volatile func)() = (flags & PEXECUTE_SEARCH ? execvp : execv);
  int pid = 0;
  int pdes[2];
  int input_desc;
  volatile int output_desc, retries, sleep_interval;
  /* Pipe waiting from last process, to be used as input for the next one.
     Value is STDIN_FILE_NO if no pipe is waiting
     (i.e. the next command is the first of a group). */
  static int last_pipe_input;

  /* If this is the first process, initialize. */
  if (flags & PEXECUTE_FIRST)
    last_pipe_input = STDIN_FILE_NO;

  input_desc = last_pipe_input;

  /* If this isn't the last process, make a pipe for its output,
     and record it as waiting to be the input to the next process. */
  if (! (flags & PEXECUTE_LAST))
    {
      if (pipe (pdes) < 0)
        {
          *errmsg_fmt = "pipe";
          *errmsg_arg = NULL;
          return -1;
        }
      output_desc = pdes[WRITE_PORT];
      last_pipe_input = pdes[READ_PORT];
    }
  else
    {
      /* Last process. */
      output_desc = STDOUT_FILE_NO;
      last_pipe_input = STDIN_FILE_NO;
    }

  /* Fork a subprocess; wait and retry if it fails. */
  sleep_interval = 1;
  for (retries = 0; retries < 4; retries++)
    {
      pid = vfork ();
      if (pid >= 0)
        break;
      sleep (sleep_interval);
      sleep_interval *= 2;
    }

  switch (pid)
    {
    case -1:
      {
#ifdef vfork
        *errmsg_fmt = "fork";
#else
        *errmsg_fmt = "vfork";
#endif
        *errmsg_arg = NULL;
        return -1;
      }

    case 0: /* child */
      /* Move the input and output pipes into place, if necessary. */
      if (input_desc != STDIN_FILE_NO)
        {
          close (STDIN_FILE_NO);
          dup (input_desc);
          close (input_desc);
        }
      if (output_desc != STDOUT_FILE_NO)
        {
          close (STDOUT_FILE_NO);
          dup (output_desc);
          close (output_desc);
        }

      /* Close the parent's descs that aren't wanted here. */
      if (last_pipe_input != STDIN_FILE_NO)
        close (last_pipe_input);

      /* Exec the program. */
      (*func) (program, argv);

      /* Note: Calling fprintf and exit here doesn't seem right for vfork. */
      fprintf (stderr, "%s: ", this_pname);
      fprintf (stderr, install_error_msg, program);
#ifdef IN_GCC
      fprintf (stderr, ": %s\n", my_strerror (errno));
#else
      fprintf (stderr, ": %s\n", strerror (errno));
#endif
      exit (-1);
      /* NOTREACHED */
      return 0;

    default:
      /* In the parent, after forking.
         Close the descriptors that we made for this child. */
      if (input_desc != STDIN_FILE_NO)
        close (input_desc);
      if (output_desc != STDOUT_FILE_NO)
        close (output_desc);

      /* Return child's process number. */
      return pid;
    }
}

int
pwait (pid, status, flags)
     int pid;
     int *status;
     int flags UNUSED;
{
  /* ??? Here's an opportunity to canonicalize the values in STATUS.
     Needed? */
#ifdef VMS
  pid = waitpid (-1, status, 0);
#else
  pid = wait (status);
#endif
  return pid;
}

#endif /* ! __MSDOS__ && ! OS2 && ! MPW && ! _WIN32 */
