#!/usr/bin/env python3
'''
находит публичный IP'шник живого хоста в автоскейл группе
прописывает его в ~/.ssh/config
убирает предыдущую запись из ~/.ssh/known_hosts и пытается добавить новую
и пытается то же самое сделать для putty
'''

# stdlib
import sys
import os
import logging
import subprocess
from typing import Iterable
# 3rd party
import boto3


def main() -> None:
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--debug',
                        '-d',
                        action='store_true',
                        help='Debug mode')
    parser.add_argument('--boto-profile', help='Boto profile name')
    parser.add_argument('--region', default='us-east-2', help='AWS region')
    parser.add_argument('--asg', required=True, help='ASG name')
    parser.add_argument('--ssh-connection',
                        default='asg',
                        help='Connection name for ~/.ssh/config')
    parser.add_argument('--putty-connection',
                        default='asg',
                        help='Connection name for PuTTY')
    args = parser.parse_args()
    logging.basicConfig(level=logging.DEBUG if args.debug else logging.INFO)

    public_ip_list = get_asg_instance_ips(args.asg, {
        'region_name': args.region,
        'profile_name': args.boto_profile
    })
    if not len(public_ip_list):
        print('No public IP found')
        sys.exit(1)
    public_ips = set(public_ip_list)
    clean_ssh_hostkeys(public_ips)
    update_ssh_connection(args.ssh_connection, public_ip_list[0])
    clean_putty_hostkeys(public_ips)
    update_putty_connection(args.putty_connection, public_ip_list[0])


def get_asg_instance_ips(asg_name: str,
                         boto3_session_args: dict[str, str]) -> list[str]:
    # Set up boto3 connection
    session = boto3.Session(**boto3_session_args)
    asg = session.client('autoscaling')
    ec2 = session.client('ec2')

    # list instances in the ASG
    asg_data = asg.describe_auto_scaling_groups(
        AutoScalingGroupNames=[asg_name])
    # {'AutoScalingGroups': [{...}], 'ResponseMetadata': {'RequestId': '10af8379-bb17-4712-a8db-af3c3222c7d7', 'HTTPStatusCode': 200, 'HTTPHeaders': {...}, 'RetryAttempts': 0}}
    asg_instances = asg_data['AutoScalingGroups'][0][
        'Instances']  # type: ignore
    instance_ids = [instance['InstanceId'] for instance in asg_instances]
    # get instance public IP
    ec2_data = ec2.describe_instances(InstanceIds=instance_ids)
    public_ip_list = []
    for r in ec2_data.get('Reservations', [{}]):
        for instance in r.get('Instances', [{}]):
            assert instance is not None
            public_ip = instance['PublicIpAddress']  # type: ignore
            state_code = instance['State']['Code']  # type: ignore
            print(
                f'{instance["InstanceId"]} {instance["State"]["Name"]} ({state_code}) {public_ip}'  # type: ignore
            )
            if state_code == 16:  # Running
                public_ip_list.append(public_ip)
    return public_ip_list


def clean_ssh_hostkeys(public_ips: Iterable[str]) -> None:
    # clean host keys
    os.system(f'ssh-keygen -R {" ".join(public_ips)}')


def update_ssh_connection(host: str, host_name: str) -> None:
    '''
    Update HostName in SSH config
    '''
    # config example:
    # Host ec2-asg-ASG-MEDIA-us-east-2
    #   User aderbenev
    #   HostName 3.20.142.149
    #   ProxyCommand c:/Users/aderbenev/AppData/Local/Programs/Git/mingw64/bin/connect.exe -S localhost:1081 %h %p
    ssh_config_dir = os.path.join(
        os.environ.get('HOME') or os.environ['USERPROFILE'], '.ssh')
    ssh_config_path = os.path.join(ssh_config_dir, 'config')
    with open(ssh_config_path, 'r') as f, open(ssh_config_path + '.new',
                                               'w') as nf:
        inblock = False
        hostline_to_look_for = f'Host {host}'.lower()
        for line in f:
            if not inblock:
                nf.write(line)
                if line.strip().lower() == hostline_to_look_for:
                    inblock = True
            else:
                if line.startswith('Host '):
                    inblock = False
                    nf.write(line)
                elif line.lstrip().startswith('HostName '):
                    prefix = line[:line.index('HostName ') + len('HostName ')]
                    nf.write(f'{prefix}{host_name}\n')
                else:
                    nf.write(line)
    os.replace(ssh_config_path, ssh_config_path + '.bak')
    os.rename(ssh_config_path + '.new', ssh_config_path)
    # update ssh host_keys
    subprocess.run([
        'ssh', '-o', 'StrictHostKeyChecking accept-new', '-o', 'BatchMode yes',
        host, 'exit'
    ],
                   stdin=subprocess.DEVNULL)


def update_putty_connection(connection_name: str, host: str) -> None:
    # if on Windows, update PuTTY config
    import winreg
    with winreg.OpenKey(
            winreg.HKEY_CURRENT_USER,
            r'Software\SimonTatham\PuTTY\Sessions' + f'\\{connection_name}', 0,
            winreg.KEY_ALL_ACCESS) as key:
        winreg.SetValueEx(key, 'HostName', 0, winreg.REG_SZ, host)


def clean_putty_hostkeys(
        public_ips_for_hostkeys_cleanup: Iterable[str]) -> None:
    import winreg
    # clean host keys
    with winreg.OpenKey(winreg.HKEY_CURRENT_USER,
                        r'SOFTWARE\SimonTatham\PuTTY\SshHostKeys', 0,
                        winreg.KEY_ALL_ACCESS) as key:
        i = 0
        while True:
            try:
                name, value, type = winreg.EnumValue(key, i)
                key_type, port_colon_host = name.split('@', maxsplit=1)
                port, host = port_colon_host.split(':', maxsplit=1)
                if host in public_ips_for_hostkeys_cleanup:
                    winreg.DeleteValue(key, name)
                else:
                    i += 1
            except OSError:
                break


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
