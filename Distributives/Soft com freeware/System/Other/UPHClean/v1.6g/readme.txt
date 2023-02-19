UPHClean v1.6g readme.txt
Updated September 14, 2010 by Robin Caron

Send all feedback/comments/problems to uphclean@microsoft.com
 
WHAT IS UPHCLEAN
================

UPHClean is a service that once and for all gets rid of problems with user
profile not unloading.

You are having profile unload problems if you experience slow logoff (with
Saving Settings for most of the time while logging off), roaming profiles
that do not reconcile, or the registry size limit is reached.

WHY DO PROFILES NOT UNLOAD?
===========================

Many system and service processes do work on behalf of users.  When the work
is done the system or service process is responsible for releasing handles it
has to the user profile hive.  If this is not done by the service as the user
logs off the profile cannot be unloaded.

This problem in code can be caused by improper coding either in Microsoft
software or 3rd party software (e.g. printer drivers, virus scanner service,
etc).  With the information provided by the system there is no way to find
out what software needs to be corrected to allow profiles to unload.

This problem can be caused for a variety of reasons.  While software developers
are typically very careful about releasing handles, developing software that
works on behalf of a logged on user is complicated.  It is difficult for
software developer to have full control over how the registry is accessed.
Service developers might want to see KB article 199190 for more information.
 
While it is possible to identify the service (see KB article 221833), it is
sometimes difficult to track this down the specific problem code.  Even when
you do identify the problem code there maybe times when the developer of this
code is not able to make the necessary changes.  This is the reason for
UPHClean -- it takes care of the problem regardless of the reason why.

WHAT DOES THE USER SEE?  WHAT HAPPENS TO THE PROFILE?
=====================================================

Windows NT4:
The system gives up immediately on failure to unload the profile
and the (roaming) profile is not reconciled.

Windows 2000:
The system attempts to unload the profile 60 times at 1 second intervals. 
This retry logic rarely helps so in most cases after 60 seconds of the user
waiting at the Saving Settings message box the system gives up and roaming
profiles are not reconciled.  The number of retries can be changed to allow the
user to log off faster (this can be done using the policy under Computer
Configuration, Administrative Template, System, User Profiles, Maximum retries
to unload and update user profile)

Windows XP and 2003:
The profile is reconciled using a copy of the contents of the registry.  The
user is not made to wait as in Windows 2000.  The problem left is that the
computer cannot recover the memory the profile uses until it can be unloaded.  

Also in some cases (e.g. using anonymous logons) you may find that you cannot
log on if the profile cannot be unloaded.

WHY SHOULD I USE UPHCLEAN?
==========================

The concept of UPHClean is to deal with these the same way the operating
system deals with other resource issues: when a task is done resources
(memory, handles, etc) are automatically reclaimed.  UPHClean accomplishes
this simply by monitoring for users to log off and verifying that unused
resources are reclaimed.  If they are not it reclaims the resource and logs
its action.  This approach is superior as it works for any known reason
that profiles do not unload and also will keep working to address new
unknown issues.

Another advantage to UPHClean is that no computer restart is required to 
install it or remove it (except on Windows NT 4).  You can install and
remove UPHClean to find out whether it helps with a profile unload problem or
not.  You can do this without having to worry about what hotfix, service pack,
feature pack, etc has been installed.  Set it and forget is the goal of
UPHClean.

By default UPHClean takes action to allow profiles to unload.  You can 
choose to have UPHClean only report what processes it finds preventing profiles
from unloading.  To do this, install UPHClean and use the registry editor to
set:

HKLM\System\CurrentControlSet\Services\UPHClean\Parameters\REPORT_ONLY to 1.

You can also have UPHClean log the call stack that is responsible for the
profile hive handle.  This is necessary to find out what software is
responsible for the hive handle in processes used for many purposes (e.g.
svchost.exe, dllhost.exe, winmgmt.exe).  To enable call stack logging use the
registry editor to set:

HKLM\System\CurrentControlSet\Services\UPHClean\Parameters\CALLSTACK_LOG to 1.

Logging the call stack is computationally and memory intensive.  You should use
this option to collect information and then turn it off.  To get more accurate
call stack logging it may be necessary to get symbols installed on the
computer.  You can read about getting symbols at:

http://www.microsoft.com/whdc/ddk/debugging/symbols.mspx

HOW CAN I TELL IF I'M HAVING A PROFILE UNLOAD PROBLEM?
======================================================

Events are recorded in the event log in most cases.  You can use Event Viewer
to look for the following events:

Windows NT 4:

The application event log has error events with source Userenv, event id
1000.  The event text is:

The operating system was unable to load your profile.  Please contact
your Network Administrator.

This is the only symptom you find in the event log of a Windows NT 4 computer
indicating this problem is present.  The only way to be sure is to use UPHClean
to find out if you have this problem or have some other problem.

Windows 2000:

The application event log has error events with source Userenv, event id
1000.  When you call up the event you get the one of following events:

Windows cannot unload your registry file.  If you have a roaming profile,
your settings are not replicated. Contact your administrator.

DETAIL - Access is denied.

- or -

Windows cannot unload your registry class file.  If you have a roaming
profile, your settings are not replicated. Contact your administrator.

DETAIL Access is denied.

- or - 

Windows cannot log you on because the profile cannot be loaded. Contact
your network administrator.

This last error is relevant if you find one of the other ones earlier
in the application log.

Windows XP and 2003:

You will see of the following error events in the application log:

Userenv/1517:

Windows saved user X registry while an application or service was still
using the registry during log off. The memory used by the user's registry
has not been freed. The registry will be unloaded when it is no longer in use.

This is often caused by services running as a user account, try configuring the
services to run in either the LocalService or NetworkService account.

Userenv/1524:

Windows cannot unload your classes registry file - it is still in use by other
applications or services. The file will be unloaded when it is no longer in use.

Userenv/1500:

Windows cannot log you on because your profile cannot be loaded. Check that you
are connected to the network, or that your network is functioning correctly. If
this problem persists, contact your network administrator. 

This last error (1500) is relevant if you find one of the other ones earlier in
the application log.

INSTALLATION
============

To automatically install it (you need uphclean-setup.msi):
- Double click the setup.msi

To manually install it (you need a copy of uphclean.exe):

- Create a directory under Program Files for the service
     (e.g. c:\program files\uphclean)
- Copy the program (uphclean.exe) to the directory
     (e.g. c:\program files\uphclean\uphclean.exe)
- Open a command prompt on the computer
- Change directory where you copied the program
     (e.g cd \program files\uphclean) 
- Run the program with the -install switch to install the service and start it
     (e.g. uphclean -install)

The service is set to automatically start when the computer boots so you will
not need to start it manually.  Below I've listed the events that you will find
in the application log when it takes positive steps to unload profile hives.

INSTALLATION PROBLEMS
=====================

If you get an error using the MSI installation package and the package is on a 
network share attempt the installation from a local drive.  Another alternative
is to use the manual installation instructions.

UPGRADING
=========

If you used the manual installation method to install UPHClean you must follow
the manual removal instructions before attempting to use the MSI package to
install.  You can find out if you used the MSI package by looking for an entry
for User Profile Hive Cleanup Service in Add/Remove Programs under Control Panel.

If you used the MSI package to install then you can proceed with the new package
without removal.

REMOVAL
=======

If you used automatic installation:
- Open Control Panel
- Open Add/Remove Programs
- Click on User Profile Hive Service and select Remove

If you manually installed:
- Run the program with the -remove switch to stop the service and remove it
  (e.g. uphclean -remove)
- Remove the UPHClean directory under c:\program files

PROBLEMS USING UPHCLEAN
=======================

Because UPHClean assists in unloading the users registry hive some services
may behave incorrectly.  Administrators are encouraged to test and watch for
unexpected behavior.  If unwanted behavior is identified contact the
developers of software that UPHClean identified as preventing profile from
unloading.

UPHClean assists the operating system to unload user profile hive by
remapping the handles to the user profile hive to the default user hive.
For example if a process has a handle to
HKEY_USERS\S-1-5-21-X-Y-Z\Software\Microsoft after remapping it would have a
handle to HKEY_USERS\.DEFAULT\Software\Microsoft.  This allows the profile
hive to unload.  This may not work if the application expects data 
that would only be available under the specific user profile hive it was
accessing since the data will not be copied.  

If you find that removing UPHClean stops a particular problem from occurring
then you may be interested in restricting UPHClean from processing certain
handles.  UPHClean ignores handles that are held opened to profile hives for
the users specified on the user exclusion list or by processes specified on the
process exclusion list.  These lists are specified using the following
registry values:

HKLM\System\CurrentControlSet\Services\UPHClean\Parameters\PROCESS_EXCLUSION_LIST

HKLM\System\CurrentControlSet\Services\UPHClean\Parameters\USER_EXCLUSION_LIST

Note that since these values are specified as REG_MULTI_SZ strings you should
use regedt32 on Windows NT and Windows 2000 to edit them.

The process exclusion list is a list of process names that UPHClean should 
ignore when determining which handles to user profile hives to act on.  Each
process name is specified on its own line when input in registry editor.  The
process name should be specified the same way as it shows in Task Manager.
Usually this is the file name of the program (e.g. notepad.exe).

A few process show multiple times in Task Manager.  It is possible to specify
that a certain DLL be loaded in the process to allow a selection of a specific
process.  This is useful with the svchost process to identify a specific
instance.  For example to specify the svchost process that the Remote Procedure
Call (RPC) service is running in on Windows 2000, Windows XP and Windows Server
2003 you would specify svchost.exe/rpcss.dll in the process exclusion list.

The user exclusion list is a list of user security identifier (SID) or user
that UPHClean should ignore when determining which handle to user profile hives
to act on.  Each user SID or name is specified on its own line when input in
registry editor.  If specifying a user name you must enter the user domain name
followed by a backslash followed by the user name.  For example
RCARONDOM\RCARON to specify the user RCARON from domain RCARONDOM.  SIDs should
be specified in the usual string format (e.g. 
S-1-5-21-2127521184-1604012920-1887927527-68486).  This is the same string you
see under HKEY_USERS in registry editor.

Note that the user exclusion list always includes the following SIDs: S-1-5-18,
S-1-5-19, S-1-5-20.  Unloading these profiles can cause problems so UPHClean
will not attempt to process handles to these profiles.

Which processes UPHClean performs handle remapping can specified using the
following registry value:

HKLM\System\CurrentControlSet\Services\UPHClean\Parameters\REMAP_HANDLE_PROCESS_LIST

The list by default contains '*' which specifies that handle remapping should
be performed for all non-excluded processes.  This list can be changed to only
include specified processes in the same manner as the process exclusion list.
Processes specified on this list can be preceeded by a '-' character to specify
that they should be excluded from handle remapping.  Any handle for a process
that is not excluded but has handle remapping turned off will be closed.

LOGGED EVENTS
=============

1) Every time the User Profile Hive Cleanup service starts:

Event Type: Information
Event Source: UPHClean
Event Category: None
Event ID: 1001
Date:  11/14/2003
Time:  10:13:45 PM
User:  N/A
Computer: RCARONDOM-DC1
Description:
User Profile Hive Cleanup Service version 1.X.Y.Z started successfully.
 
2) Every time it stops:

Event Type: Information
Event Source: UPHClean
Event Category: None
Event ID: 1010
Date:  7/11/2003
Time:  11:12:06 PM
User:  N/A
Computer: RCARONDOM-DC1
Description:
User Profile Hive Cleanup Service stopped successfully.
 
3) Here the service is telling you that it closed handles that were preventing
the profile from unloading:

Event Type:	Information
Event Source:	UPHClean
Event Category:	None
Event ID:	1201
Date:		11/14/2003
Time:		10:26:29 PM
User:		RCARONDOM\u1
Computer:	RCARONDOM-DC1
Description:
The following handles in user profile hive RCARONDOM\u1
(S-1-5-21-3230802392-3390281410-1560515013-1307) have been closed because they
were preventing the profile from unloading successfully:
 
profleak.exe (1444)
  HKCU (0x144)
 
If you have call stack logging the event will look like this:

Event Type:	Information
Event Source:	UPHClean
Event Category:	None
Event ID:	1201
Date:		10/21/2003
Time:		5:17:38 PM
User:		RCARONDOM-DC1\u1
Computer:	RCARONDOM-DC1
Description:
The following handles in user profile hive RCARONDOM-DC1\u1
(S-1-5-21-3230802392-3390281410-1560515013-1307) have been closed because they
were preventing the profile from unloading successfully:
 
profleak.exe (2604)
  HKCU (0x80)
      0x77dfc200 ADVAPI32!TrackObject+0xe
      0x00412112 profleak!<no symbol>
      0x77db571b ADVAPI32!ScSvcctrlThreadA+0xe
  HKCU\Software\Policies (0x88)
      0x77dfc200 ADVAPI32!TrackObject+0xe
      0x77da1949 ADVAPI32!RegOpenKeyExW+0x10b
      0x0041350c profleak!<no symbol>
      0x00412112 profleak!<no symbol>
      0x77db571b ADVAPI32!ScSvcctrlThreadA+0xe
 
4) Here's what it looks like if there's a problem closing handle held by 
application.

Event Type: Information
Event Source:   UPHClean
Event Category: None
Event ID: 1211
Date:     7/11/2003
Time:     9:46:29 PM
User:     RCARONDOM\u1
Computer: RCARONDOM-DC1
Description:
The following handles opened in user profile hive RCARONDOM\u1 
(S-1-5-21-3230802392-3390281410-1560515013-1307) could not be closed:

profleak.exe (1148)
  HKCU\SOFTWARE\Policies (0xb0) error 6
 
5) Here the service is telling you that the user profile hive could not be 
unloaded and that it will try again later.  I expect that this will occur 
if the 1211 event occurred.  As I don't expect 1211 to occur I'd expect that 
event id 1111 will not occur either.

Event Type: Warning
Event Source: UPHClean
Event Category: None
Event ID: 1111
Date:  7/11/2003
Time:  9:46:50 PM
User:  RCARONDOM\u1
Computer: RCARONDOM-DC1
Description:
User profile hive RCARONDOM\u1 (S-1-5-21-3230802392-3390281410-1560515013-1307)
failed to unload.  The unload will be retried. 
 
6) If you are using the reporting only mode (see above on how to set) you will
get event id 1501 whenever UPHClean detects a user logging off and the profile
being held:

Event Type: Information
Event Source: uphclean
Event Category: None
Event ID: 1501
Date:  7/11/2003
Time:  11:19:49 PM
User:  RCARONDOM\u1
Computer: RCARONDOM-DC1
Description:
The following handles opened in user profile hive RCARONDOM\u1
(S-1-5-21-3230802392-3390281410-1560515013-1307) are preventing profiles from
unloading:

profleak.exe (1364)
  HKCU\SOFTWARE\Policies (0xb4)
  HKCU (0xb8)
 
7) If you are using the reporting only mode (see above on how to set) you will
get event id 1511 whenever UPHClean detects a hive loaded for an extended
period of time if the user is not logged on (whether there are handles
to it or not).  This is important because it is possible that terminal
server could run out of kernel mode resource (paged pool memory) when that
happens.  This could lead to users being prevented from logging on.

Event Type:	Information
Event Source:	UPHClean
Event Category:	None
Event ID:	1511
Date:		10/21/2003
Time:		5:13:18 PM
User:		RCARONDOM\u1
Computer:	RCARONDOM
Description:
User profile hive RCARONDOM\u1 (S-1-5-21-3230802392-3390281410-1560515013-1307)
is loaded even though user is not logged on.

8) If you use handle remapping instead of getting event id 1201 logged you will
get event 1401:

Event Type:	Information
Event Source:	UPHClean
Event Category:	None
Event ID:	1401
Date:		10/26/2004
Time:		9:56:52 PM
User:		RCARON2-NC\u1
Computer:	RCARON2-NC
Description:
The following handles in user profile hive RCARON2-NC\u1
(S-1-5-21-796845957-1275210071-1801674531-1024) have been remapped because they
were preventing the profile from unloading successfully: 
 
regopenkeyex.exe (368)
  HKCU\Software\Classes\Software (0x4)

UPHCLEAN HISTORY
================

Sep 14, 2010 v1.6g (build 1.6.36.0)

The previous version of UPHClean did not call the system executable using
quotes. This could in some scenarios allow a local user to elevate privileges.
This issue has now been addressed in the current version. Thanks to Thierry
Zoller from Verizon Business for reporting this issue to us.

The C runtime files (MSVCRT.DLL and MSVCP60.DLL) are no longer needed as
UPHClean uses statically linked versions of those files.

May 23, 2006 v1.6f (build 1.6.33.0)

For UPHClean v1.6d STOP CE could only happen during uninstallation.  This
build includes code to correct the uninstallation scenario.  Fixed data
corrupting bug that is exposed when UPHClean is repeatedly installed and
uninstalled.  Modified remapping handle code to use handle under
HKU\.Default\UPHClean or under HKU\.Default_Classes\UPHClean.

Nov 24, 2005 v1.6e (build 1.6.31.0)

UPHClean was fixed to correct a problem in handling deleted registry key names
that include non ANSI characters.  This problem could cause a STOP 50 to occur.

Apr 27, 2005 v1.6d (build 1.6.30.0)

If a user is logging off and the user profile hive is not unloading and 
UPHClean is stopped it is possible that a STOP CE could occur.  To avoid
this UPHClean delays has been modified to only complete its cleanup to 
when it is being uninstalled.

Fixed error in UPHClean that could cause STOP 93 when protected handles were
closed.

Added registry setting DISABLEREGFLUSHKEY.  This setting prevents user profile
unload from causing a registry flush to disk.  In some cases poor performance
affecting user application in other sessions can occur from doing this
flushing.  The setting defaults to 0 which has no effect.  Setting it to 1
prevents user profile unload from causing registry flushing.

Mar 15, 2005 v1.6b (build 1.6.0.26)

Fixed issue with handle remapping where if a handle to a profile hive is
protected from close UPHClean would cause high CPU usage for large periods of
time.

Handle remapping is now the default for all processes instead of handle closure.

Nov 12, 2004 v1.6 (build 1.6.0.24)

Added code to prevent UPHClean from closing handles held to user profile hives.
This can be done using by user or process restriction.  Added code to allow
remapping of handles.  This must be enabled by indicating which process
remapping should be done for.

Corrected problem when on Windows 2000 if UPHClean had trouble closing handles
to user profile hive logoff times could increase to about 15 minutes.

Corrected problem when stopping the UPHClean service while a user profile was
being unloaded which could cause the machine to crash.

Corrected code to log UPHClean stop event (event id 1010) when system is
shutdown.

Added code to set service description on Windows 2000 and later operating
system.

Mar 4, 2004 v1.5e (build 1.5.4.21)

Added code to handle closure of handles for registry keys that were deleted.
This covers scenarios where an application keeps a handle to a deleted
registry key.  In that case Userenv would log profile unload problem events
even if UPHClean was running.

Feb 25, 2004 v1.5d (build 1.5.4.20)

Added code to force closure of registry handles protected from close.  This
avoids repeated events 1201 with the same process/handle combinations at 10
second intervals.  Modified code to avoid license violation error on NT4.

Feb 12, 2004 v1.5c (build 1.5.0.18)

Cleaned up event 1201 message text.  Added code to delay initial scan for 
profiles until operating system has been started for 1 minute.  Added logging
code for event id 1501 to include user name.  First version available through
Microsoft download.

Jan 14, 2004 v1.5b (build 1.5.0.11)

Improved detection of profile hive unload problem to allow UPHClean to release
hive handles earlier than before allowing normal system function.  With this
change the UPHClean 1201 event will be the only event logged.

Jan 5, 2004 v1.5 (build 1.5.0.8)

Added code to allow the call stack to be logged.  Modified code to handle
scenario where UPHClean would not clean up profile handles if the profile is
deleted at log off.

Sep 23, 2003 v1.2 (build 1.2.0.7)

Modified code to allow it to run on Windows NT 4.  Also added code to allow
UPHClean to be used in monitoring mode.  In this mode UPHClean reports what
process had handles to registry keys in user profile hives.  The name of the
process, its id, the registry key name reported.

Sep 8, 2003 v1.1 (build 1.1.0.4)

Modified code flow to allow UPHClean to work on computers that do not have
terminal services.  Modified code to immediately close handles to profile hives
upon detection of user logoff.  The user can log off 20 seconds faster that way.

Jul 31, 2003 v1.0 (build 1.0.0.2)

First working version.

WORK FLOW
=========

	hivestatus: hive name, prior refcount, refcount
	hivetounload: hive name, next attempt (60 seconds)
	pendinghiveunload: hive name, next attempt (10 seconds), last attempt (60 mins)
	handletoclose: handle info

    wait until computer has been up for 1 minute

	on profile list change notify or service done or timeout (10 seconds if !pendinghiveunload.empty else 60 seconds)
		if service done -- exit

		iterate through hive status:
			prior refcount = refcount
			update refcount
			if refcount = 0 and loaded then
				if prior refcount != 0 then
					remove hive from hivetounload
					add hive to pendinghiveunload
						(next attempt = now, last attempt = now + 65 mins)
			else
				remove hive from hivetounload
				remove hive from pendinghiveunload

		iterate through pendinghiveunload
			if last attempt passed then 
				move hive to hivetounload (next attempt = now)

		if !pendinghiveunload.empty or !hivetounload.empty then
			handletoclose = null
			get handlelist
			iterate through handlelist
				if (start(handle.name) in pendinghiveunload and nextattempt <= now) or
						(start(handle.name) in hivetounload and nextattempt <= now) then
					add entry to handletoclose

		process handletoclose (all handles on list are to be closed)

		process hivetounload (hives with nextattempt <= now should be unloaded)
			no need to remove from list (will get done at next hive status update)

