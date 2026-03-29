""" A simple TOTP token generator,
    can read the secret from a file or directly from the command line.
"""
import base64
import hashlib
import hmac
import struct
import sys
import time
import re
from pathlib import Path


def generate_totp(secret: str, interval: int = 30, digits: int = 6) -> str:
    counter = int(time.time() // interval)
    normalized_secret = secret.replace(" ", "").upper()
    padding = "=" * ((8 - (len(normalized_secret) % 8)) % 8)
    key = base64.b32decode(normalized_secret + padding, casefold=True)
    msg = struct.pack(">Q", counter)
    digest = hmac.new(key, msg, hashlib.sha1).digest()
    offset = digest[-1] & 0x0F
    code = struct.unpack(">I", digest[offset:offset + 4])[0] & 0x7FFFFFFF
    return str(code % (10**digits)).zfill(digits)


def main() -> None:
    if len(sys.argv) < 2:
        print(
            __doc__, 'Usage: python totp_token.py <BASE32_SECRET_OR_PATH> '
            '[<LINE_NUMBER_IN_FILE>]',
            sep='\n',
            file=sys.stderr)
        raise SystemExit(1)

    p = Path(sys.argv[1])
    if re.fullmatch(r'[ A-Za-z2-7]+', sys.argv[1]) and not p.is_file():
        secret = sys.argv[1]
    else:
        if not p.is_file():
            print(
                f'Error: {sys.argv[1]!r} is not a valid file '
                'and neither a valid base32 secret.',
                file=sys.stderr)
            raise FileNotFoundError(sys.argv[1])
        try:
            line_number = int(sys.argv[2])
        except (IndexError, ValueError):
            line_number = 1
        with p.open() as f:
            for i, line in enumerate(f, start=1):
                if i == line_number:
                    secret = line.rstrip('\n')
                    break

    sys.stdout.write(generate_totp(secret))


if __name__ == "__main__":
    main()
