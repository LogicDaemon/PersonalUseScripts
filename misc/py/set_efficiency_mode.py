# Define the PROCESS_pPState structure
class PROCESS_pPState(ctypes.Structure):
    _fields_ = [
        ('Version',     wintypes.ULONG),
        ('ControlMask', wintypes.ULONG),
        ('StateMask',   wintypes.ULONG)
    ]

def enable_on_eco_mode():
    # Constants from the Windows API
    PROCESS_POWER_THROTTLING_EXECUTION_SPEED = 0x1
    PROCESS_POWER_THROTTLING_CURRENT_VERSION = 1
    ProcessPowerThrottling = 4
    PROCESS_QUERY_INFORMATION = 0x0400
    PROCESS_SET_INFORMATION = 0x0200
    IDLE_PRIORITY_CLASS = 0x00000040 # Base Priority 4

    kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
    pid = kernel32.GetCurrentProcessId()

    pPState = PROCESS_pPState()
    pPState.Version = PROCESS_POWER_THROTTLING_CURRENT_VERSION
    pPState.ControlMask = PROCESS_POWER_THROTTLING_EXECUTION_SPEED
    pPState.StateMask = PROCESS_POWER_THROTTLING_EXECUTION_SPEED

    # Setup the necessary functions from Windows API
    GetLastError = windll.kernel32.GetLastError

    SetPriorityClass = kernel32.SetPriorityClass

    SetProcessInformation = windll.kernel32.SetProcessInformation
    SetProcessInformation.argtypes = (
        wintypes.HANDLE,
        wintypes.DWORD,
        wintypes.LPVOID,
        wintypes.DWORD,
    )
    SetProcessInformation.restype = wintypes.BOOL

    OpenProcess = windll.kernel32.OpenProcess
    OpenProcess.argtypes = (
        wintypes.DWORD,
        wintypes.BOOL,
        wintypes.DWORD,
    )
    OpenProcess.restype = wintypes.HANDLE

    # Get the current process handle
    hProcess = OpenProcess(
        PROCESS_QUERY_INFORMATION | PROCESS_SET_INFORMATION,
        False,  # Don't inherit the handle
        pid
    )
    if hProcess == 0:
        raise Exception(f'could not open process pid {pid} error={GetLastError()}')

    # Change the BasePriority in Windows from 8 (NORMAL_PRIORITY_CLASS) to 4 (IDLE_PRIORITY_CLASS)
    result = SetPriorityClass(hProcess, IDLE_PRIORITY_CLASS)

    if not result:
        # Get the last error code
        error_code = GetLastError()
        print(f"SetPriorityClass failed to lower priority. Error code: {error_code}")

    # Set the process information to enable Efficiency Mode
    result = SetProcessInformation(
        hProcess,
        ProcessPowerThrottling,
        ctypes.byref(pPState),
        ctypes.sizeof(pPState),
    )

    if result:
        print(f"Efficiency Mode enabled for this script. The green leaf should appear in Task Manager.")
    else:
        # Get the last error code
        print(f"Failed to enable Efficiency Mode. Error code: {error_code}")
        
        error_code = GetLastError()

        # Common error codes and their meanings
        if error_code == 5:
            print("Error 5: Access Denied. Ensure you're running the script as Administrator.")
        elif error_code == 87:
            print("Error 87: Invalid Parameter. Check the parameters passed to SetProcessInformation.")
        elif error_code == 6:
            print("Error 6: Invalid Handle. Ensure the process handle is valid.")
        else:
            print("Unknown error. Check your Windows version and permissions.")

    # Verify the QoS has been set to EcoQoS
    pPState.ControlMask = 0
    pPState.StateMask = 0

    verify_result = ctypes.windll.kernel32.GetProcessInformation(
        hProcess,
        ProcessPowerThrottling,
        ctypes.byref(pPState),
        ctypes.sizeof(pPState),
    )

    if verify_result:
        print("Power throttling state verified successfully.\n")
    else:
        error_code = GetLastError()
        print(f"Failed to verify power throttling state. Error code: {error_code}")

    # Close the process handle
    kernel32.CloseHandle(hProcess)
