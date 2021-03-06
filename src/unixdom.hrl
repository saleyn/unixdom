%%%----------------------------------------------------------------------
%%% File    : unixdom.hrl
%%% Summary : EDTK implementation of UNIX domain socket driver (incomplete!)
%%%
%%%
%%% NOTICE: This file was generated by the tools of the Erlang Driver
%%%         toolkit.  Do not edit this file by hand unless you know
%%%         what you're doing!
%%%
%%% Copyright (c) 2004, Scott Lystig Fritchie. All rights reserved.
%%% 5-Oct-2007 - Minor TCP compatibility additions done by Serge Aleynikov <saleyn@gmail.com�
%%% See the file "LICENSE" at the top of the source distribution for
%%% full license terms.
%%%
%%%----------------------------------------------------------------------

-define(DRV_NAME, "unixdom").

-define(MAX_UINT32, 16#FFFFFFFF).

-define(LEN_NUL_TERM, ?MAX_UINT32).

%%%
%%% Driver<->emulator communication codes (xref with top of unixdom.h)
%%%

-define(S1_DEBUG,                       0).
-define(S1_NULL,                        1).
-define(S1_OPEN,                        2).
-define(S1_GETFD,                       3).
-define(S1_CLOSEFD,                     4).
-define(S1_SENDFD,                      5).
-define(S1_RECEIVEFD,                   6).
-define(S1_CLOSE,                       7).
-define(S1_WRITE,                       8).
-define(S1_READ,                        9).

%%%
%%% Constants
%%%


%%%
%%% Verbatim stuff
%%%


%%%
%%% End of autogenerated code
%%%  script = ../../edtk/hrl_template.gsl
%%%  filename = unixdom.xml
%%%  gslgen version = 2.000 Beta 1
%%%  date = 2007/10/20
%%%  time = 21:49:41
%%%
