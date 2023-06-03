#!/usr/bin/env python3
'''
Module Docstring
'''

from __future__ import annotations, generator_stop

import gevent
import gevent.monkey

gevent.monkey.patch_all()

# Python Standard Library modules, see https://docs.python.org/3/py-modindex.html
from typing import (Callable, Optional, NoReturn, cast)
import argparse
import glob
import logging
import os
import sys
import time

# Installable modules, see https://pypi.org/
from imwatermark import WatermarkEncoder, WatermarkDecoder
import cv2

log = logging.getLogger(
    os.path.basename(__file__) if __name__ == '__main__' else __name__)


class CLIApp:
    args: Optional[argparse.Namespace]
    parser: argparse.ArgumentParser

    def __init__(self):
        self.args = None
        self.parser = parser = argparse.ArgumentParser(
            description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter)

        parser.add_argument('action', choices=('embed', 'extract'))
        parser.add_argument('input', help='path to input file or shell glob')
        parser.add_argument('--output',
                            '-o',
                            help='path to output file or directory')
        parser.add_argument('--recursive',
                            '-r',
                            action='store_true',
                            help='Use recursive shell glob')
        parser.add_argument('--type',
                            '-t',
                            default='bytes',
                            choices=('bytes', 'base16', 'bits', 'uuid',
                                     'ipv4'),
                            help='%(choices)s (default is %(default)s')
        parser.add_argument('--method',
                            '-m',
                            default='maxDct',
                            choices=('dwtDct', 'dwtDctSvd', 'rivaGan'),
                            help='%(choices)s (default is %(default)s')
        parser.add_argument('--watermark',
                            '-w',
                            default='',
                            help='embedded string')
        parser.add_argument(
            '--length',
            '-l',
            default=0,
            type=int,
            help=
            'watermark bits length, required for bytes|base16|bits watermark')
        loglevel_parser = parser.add_mutually_exclusive_group()
        loglevel_parser.add_argument('--log-level',
                                     choices=('CRITICAL', 'ERROR', 'WARNING',
                                              'INFO', 'DEBUG', 'NONE'))
        loglevel_parser.add_argument('--log-level-int',
                                     type=int,
                                     help='numeric log level')
        loglevel_parser.add_argument('--debug',
                                     '-d',
                                     action='store_true',
                                     help='Debug mode')

    def process_args(self) -> Callable:
        self.args = args = self.parser.parse_args()
        level = (logging.DEBUG
                 if args.debug else args.log_level_int if args.log_level_int
                 is not None else getattr(logging, args.log_level)
                 if args.log_level is not None else logging.INFO)
        logging.basicConfig(level=level)
        return getattr(self, args.action)

    def embed(self) -> None:
        if self.args is None:
            self.process_args()
        args = self.args
        assert args is not None

        input_paths: list[str] = glob.glob(args.input,
                                           recursive=args.recursive)
        log.debug('Input paths: %s', input_paths)
        if not input_paths:
            raise ValueError(f'No files found matching {args.input}')
        out_base: str = args.output
        if len(input_paths) == 1:
            self.embed_in_single_file(input_paths[0], out_base)
            return
        glob_prefix = os.path.dirname(
            cast(str, args.input).split('?', 1)[0].split('*', 1)[0])

        def file_thread(ifp):
            nonlocal glob_prefix, out_base
            ifp_noprefix = ifp.removeprefix(glob_prefix)
            out_suffix = '.' + ifp_noprefix if ifp_noprefix is not None else ifp
            log.debug('Input file path without prefix: %s\nOutput suffix: %s',
                      ifp_noprefix, out_suffix)
            self.embed_in_single_file(ifp, os.path.join(out_base, out_suffix))

        threads = [gevent.spawn(file_thread, ifp) for ifp in input_paths]
        gevent.wait(threads)

    def embed_in_single_file(self, input_file_path: str,
                             output_file_path: str) -> None:
        args = self.args
        assert args is not None
        log.debug('Creating WatermarkEncoder')
        encoder = WatermarkEncoder()
        if args.method == 'rivaGan':
            log.debug('Loading model for rivaGan')
            WatermarkEncoder.loadModel()
        log.debug('Reading image %s', input_file_path)
        bgr = cv2.imread(input_file_path)
        watermark_arg: str = args.watermark
        # this is how it is done in the script supplied with the module
        if args.type == 'bytes':
            encoded_watermark = watermark_arg.encode('utf-8')
            encoded_watermark_len = len(encoded_watermark) * 8
            encoder.set_watermark(args.type, encoded_watermark)  # type: ignore
        elif args.type == 'base16':
            encoded_watermark = watermark_arg.upper().encode('utf-8')
            encoded_watermark_len = len(encoded_watermark) * 8
            encoder.set_watermark(encoded_watermark)  # type: ignore
        elif args.type == 'bits':
            encoded_watermark_len = len(watermark_arg)
            encoder.set_watermark(args.type, [
                1 if c in ('y', 'Y', '1', '+', 'I') else 0
                for c in watermark_arg
            ])  # type: ignore
        else:
            assert args.type in ('ipv4', 'uuid'), 'Unknown watermark type'
            encoded_watermark_len = 32 if args.type == 'ipv4' else 128
            encoder.set_watermark(args.type, watermark_arg)  # type: ignore
        start = time.monotonic()
        log.debug('Starting encoding using watermark %s %s (length=%i)', args.type,
                  watermark_arg, encoded_watermark_len)
        bgr_encoded = encoder.encode(bgr, args.method)
        if log.isEnabledFor(logging.INFO):
            log.info('watermark length: %s', encoder.get_length())
            log.info('encode time: %f', time.monotonic() - start)
        log.debug('Writing output file to %s', output_file_path)
        cv2.imwrite(output_file_path, bgr_encoded)

    def extract(self) -> None:
        if self.args is None:
            self.process_args()
        args = self.args
        assert args is not None
        if args.type in ('bytes', 'bits', 'base16'):
            if args.length <= 0:
                sys.stderr.write(
                    'length is required for bytes watermark decoding\n')
                sys.exit(1)
            wmType = args.type
            decoder = WatermarkDecoder(wmType, args.length)
        else:
            decoder = WatermarkDecoder(args.type)
        if args.method == 'rivaGan':
            WatermarkDecoder.loadModel()
        bgr = cv2.imread(args.input)
        start = time.time()
        wm = cast(bytes, decoder.decode(bgr, args.method))
        if log.isEnabledFor(logging.INFO):
            print('decode time ms:', (time.time() - start) * 1000)
        log.debug('Raw watermark: %s', wm)
        if args.type in ('bytes', 'base16'):
            log.debug('Decoding to utf-8 because type is %s', args.type)
            print(wm.decode('utf-8'))
        else:
            log.debug('Outputting the watermark as is becase type is %s',
                      args.type)
            print(wm)


def main() -> NoReturn:
    CLIApp().process_args()()
    sys.exit()


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
