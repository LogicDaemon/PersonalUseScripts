#!/usr/bin/env python3

# import modules used here -- sys is a very standard one
import os
import sys
import httpx
import xmltodict
import werkzeug
import datetime

cl = httpx.Client(http2=True, timeout=60)


def download_with_timestamp_from_server(
        url: str, fail_when_no_last_modified_header: bool = False):
    with cl.stream('GET', url) as r:
        r.raise_for_status()
        print(r.headers)
        content_disp = r.headers.get('content-disposition')
        local_filename = werkzeug.utils.secure_filename(
            werkzeug.http.parse_options_header(
                r.headers.get('content-disposition'))[1]['filename']
            if content_disp is not None else url.rsplit('/', 1)[1])
        last_modified = werkzeug.http.parse_date(
            r.headers.get('last-modified'))
        print(
            f'Remote file {local_filename},',
            f'modified {last_modified}'
            if last_modified else 'without last-modified header',
        )
        if last_modified:
            # check time of existing file
            # current_file = os.path.join(os.getcwd(), local_filename)
            if os.path.exists(local_filename):
                current_time = os.path.getmtime(local_filename)
                if current_time == last_modified:
                    print('File is up to date')
                    return
                print(
                    'Current file exists but has different timestamp,',
                    datetime.datetime.fromtimestamp(current_time),
                )
        else:
            if fail_when_no_last_modified_header:
                print('Skipping')
                return

        os.makedirs('temp', exist_ok=True)
        tempf = os.path.join('temp', local_filename)
        with open(tempf, 'wb') as f:
            for chunk in r.iter_bytes(chunk_size=65536):
                # If you have chunk encoded response uncomment if
                # and set chunk_size parameter to None.
                # if chunk:
                f.write(chunk)
            last_modified_timestamp = datetime.datetime.timestamp(
                last_modified)
            os.utime(tempf, (last_modified_timestamp, last_modified_timestamp))
        os.replace(tempf, local_filename)

    # Command line args are in sys.argv[1], sys.argv[2] ..
    # sys.argv[0] is the script name itself and can be ignored


# Gather our code in a main() function
def main() -> None:
    download_with_timestamp_from_server(
        xmltodict.parse(cl.get(
            sys.argv[1]).text)['rss']['channel']['item']['enclosure']['@url'],
        bool(sys.argv[2]) if len(sys.argv) > 2 else False)


# Standard boilerplate to call the main() function to begin
# the program.
if __name__ == '__main__':
    main()
