#!/usr/bin/env python3
'''
находит публичный IP'шник живого хоста в автоскейл группе
прописывает его в ~/.ssh/config
убирает предыдущую запись из ~/.ssh/known_hosts и пытается добавить новую
и пытается то же самое сделать для putty
'''

import sys
import os
import logging
import subprocess
import boto3


def main():
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--debug',
                        '-d',
                        action='store_true',
                        help='Debug mode')
    parser.add_argument('--region',
                        '-r',
                        default='us-east-2',
                        help='AWS region')
    parser.add_argument('--asg', '-a', default='ASG-MEDIA', help='ASG name')
    parser.add_argument('--connection',
                        '-c',
                        default='ec2-asg-ASG-MEDIA-us-east-2',
                        help='Connection name')
    args = parser.parse_args()
    logging.basicConfig(level=logging.DEBUG if args.debug else logging.INFO)

    region = args.region
    asg_name = args.asg
    connection_name = args.connection

    # Set up boto3 connection
    session = boto3.Session(region_name=region)
    asg = session.client('autoscaling', region_name=region)
    ec2 = session.client('ec2', region_name=region)

    # list instances in the ASG
    asg_data = asg.describe_auto_scaling_groups(
        AutoScalingGroupNames=[asg_name])
    # {'AutoScalingGroups': [{...}], 'ResponseMetadata': {'RequestId': '10af8379-bb17-4712-a8db-af3c3222c7d7', 'HTTPStatusCode': 200, 'HTTPHeaders': {...}, 'RetryAttempts': 0}}
    asg_instances = asg_data['AutoScalingGroups'][0]['Instances']
    instance_ids = [instance['InstanceId'] for instance in asg_instances]
    # get instance public IP
    ec2_data = ec2.describe_instances(InstanceIds=instance_ids)
    public_ip_list = []
    for r in ec2_data.get('Reservations', [{}]):
        for instance in r.get('Instances', [{}]):
            public_ip = instance.get('PublicIpAddress')
            state_code = instance.get('State').get('Code')
            print(
                f'{instance.get("InstanceId")} {instance.get("State").get("Name")} ({state_code}) {public_ip}'
            )
            if state_code == 16:  # Running
                public_ip_list.append(public_ip)
    if not len(public_ip_list):
        print('No public IP found')
        sys.exit(1)
    public_ips = set(public_ip_list)
    ip = public_ip_list[0]

    # update HostName in SSH config
    # Host ec2-asg-ASG-MEDIA-us-east-2
    #   User aderbenev
    #   HostName 3.20.142.149
    #   ProxyCommand c:/Users/aderbenev/AppData/Local/Programs/Git/mingw64/bin/connect.exe -S localhost:1081 %h %p

    ssh_config_dir = os.path.join(
        os.environ.get('HOME', os.environ.get('USERPROFILE')), '.ssh')
    ssh_config_path = os.path.join(ssh_config_dir, 'config')
    with open(ssh_config_path, 'r') as f, open(ssh_config_path + '.new',
                                               'w') as nf:
        inblock = False
        hostline_to_look_for = f'Host {connection_name}'.lower()
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
                    prefix = line[:line.index('HostName ')+len('HostName ')]
                    nf.write(f'{prefix}{ip}\n')
                else:
                    nf.write(line)
    os.replace(ssh_config_path, ssh_config_path + '.bak')
    os.rename(ssh_config_path + '.new', ssh_config_path)
    # clean host keys
    ssh_knownhosts_path = os.path.join(ssh_config_dir, 'known_hosts')
    with open(ssh_knownhosts_path,
              'r') as f, open(ssh_knownhosts_path + '.new', 'w') as nf:
        for line in f:
            addresses_in_line = set(line.split(maxsplit=1)[0].split(','))
            if not (addresses_in_line & public_ips):
                nf.write(line)
    # os.replace(ssh_knownhosts_path, ssh_knownhosts_path + '.bak')
    os.replace(ssh_knownhosts_path + '.new', ssh_knownhosts_path)

    # if on Windows, update PuTTY config
    if sys.platform == 'win32':
        import winreg
        with winreg.OpenKey(
                winreg.HKEY_CURRENT_USER,
                r'Software\SimonTatham\PuTTY\Sessions' +
                f'\\{connection_name}', 0, winreg.KEY_ALL_ACCESS) as key:
            winreg.SetValueEx(key, 'HostName', 0, winreg.REG_SZ, ip)

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
                    if host in public_ips:
                        winreg.DeleteValue(key, name)
                    else:
                        i += 1
                except OSError:
                    break

    # update ssh host_keys
    subprocess.run([
        'ssh', '-o', 'StrictHostKeyChecking accept-new', '-o', 'BatchMode yes',
        connection_name, 'exit'
    ],
                   stdin=subprocess.DEVNULL)


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
