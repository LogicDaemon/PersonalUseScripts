#!/usr/bin/env python3

import sys
import pkg_resources
from subprocess import call

packages = [dist.project_name for dist in pkg_resources.working_set]  # pylint: disable=not-an-iterable
print(packages)
call(f'"{sys.executable}" -m pip install --upgrade --upgrade-strategy eager ' + ' '.join(packages), shell=True)
