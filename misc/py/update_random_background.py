#!/usr/bin/env python3

import ctypes
import pathlib
import random
import uuid
from ctypes import wintypes


def get_pictures_directory() -> pathlib.Path:
    # Define the GUID for the Pictures folder
    FOLDERID_Pictures = uuid.UUID('{33E28130-4E1E-4676-835A-98395C3BC3BB}')

    # Convert UUID to ctypes GUID structure
    class GUID(ctypes.Structure):
        _fields_ = [("Data1", wintypes.DWORD), ("Data2", wintypes.WORD),
                    ("Data3", wintypes.WORD), ("Data4", ctypes.c_ubyte * 8)]

    guid = GUID(
        FOLDERID_Pictures.time_low,
        FOLDERID_Pictures.time_mid,
        FOLDERID_Pictures.time_hi_version,
        (ctypes.c_ubyte * 8)(*FOLDERID_Pictures.bytes[8:]),
    )

    # Setup the function call
    SHGetKnownFolderPath = ctypes.windll.shell32.SHGetKnownFolderPath
    SHGetKnownFolderPath.argtypes = [
        ctypes.POINTER(GUID), wintypes.DWORD, wintypes.HANDLE,
        ctypes.POINTER(ctypes.c_wchar_p)
    ]
    SHGetKnownFolderPath.restype = ctypes.HRESULT

    path_ptr = ctypes.c_wchar_p()
    if SHGetKnownFolderPath(
            ctypes.byref(guid), 0, None, ctypes.byref(path_ptr)) != 0:
        raise OSError("Failed to get Pictures directory path")

    assert path_ptr.value is not None, "Path pointer is None"
    return pathlib.Path(path_ptr.value)


def main() -> None:
    # find a windows user's Pictures directory
    pictures_dir = get_pictures_directory()

    pics = []
    for picture in (pictures_dir / 'Backgrounds/jpg').iterdir():
        if picture.is_file() and picture.suffix.lower() in ['.jpg', '.jpeg']:
            pics.append(picture)

    if not pics:
        raise FileNotFoundError("No pictures found in the specified directory")

    # create a symlink pictures_dir / 'Backgrounds/selected.jpg' to a random picture
    selected_pic = pics[random.randint(0, len(pics) - 1)]
    symlink_path = pictures_dir / 'Backgrounds/selected.jpg'
    if symlink_path.exists():
        symlink_path.unlink()
    symlink_path.hardlink_to(selected_pic)


if __name__ == "__main__":
    main()
