#!/usr/bin/env python3

# import modules used here -- sys is a very standard one
#import sys
import os
import requests
import json
import configparser
import appdirs


# Gather our code in a main() function
def main():
    config = readConfig()
    wiki_base_URL = config['DEFAULT']['base_url']
    # Command line args are in sys.argv[1], sys.argv[2] ..
    # sys.argv[0] is the script name itself and can be ignored
    r = requests.get(f'{wiki_base_URL}/confluence/rest/api/content',
                     params={'title': config['DEFAULT']['page_title']}, # 'Corporate+VPN+subnets'
                     auth=(config['DEFAULT']['username'], config['DEFAULT']['password']), timeout=30)
    printResponse(r)
    # parentPage = r.json()['results'][0]
    # pageData = {
    #     'type': 'comment',
    #     'container': parentPage,
    #     'body': {
    #         'storage': {
    #             'value': "<p>A new comment</p>",
    #             'representation': 'storage'
    #         }
    #     }
    # }
    # r = requests.post('http://localhost:8080/confluence/rest/api/content',
    #                   data=json.dumps(pageData),
    #                   auth=(config['DEFAULT']['username'], config['DEFAULT']['password']),
    #                   headers=({
    #                       'Content-Type': 'application/json'
    #                   }))
    printResponse(r)


def printResponse(r):
    print(
        f'{json.dumps(r.json(), sort_keys=True, indent=4, separators=(",", ": "))} {r}\n'
    )


def readConfig() -> configparser.ConfigParser:
    config = configparser.ConfigParser()
    config.read(
        os.path.join(appdirs.user_config_dir(appname=__file__),
                      'wiki_parser.ini'))
    if os.name == 'nt':
        secretPath = os.path.join(os.getenv('LOCALAPPDATA', '.'), '_sec',
                                   'wiki.txt')
    else:
        secretPath = os.path.join(appdirs.user_config_dir(appname=__file__),
                                   'secrets.txt')
    with open(secretPath, 'r', encoding='utf-8') as f:
        config['DEFAULT']['username'] = f.readline().strip()
        config['DEFAULT']['password'] = f.readline().strip()
    return config


# Standard boilerplate to call the main() function to begin
# the program.
if __name__ == '__main__':
    main()
