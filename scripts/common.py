import os
import subprocess
import boto3
import time
import sys


def execute(cmds, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=os.environ):
    p = subprocess.Popen(cmds, stdout=stdout, stderr=stderr, env=env)
    stdout_data, stderr_data = p.communicate()
    if p.returncode != 0:
        raise RuntimeError('%s \n %s' % (str(stdout_data), str(stderr_data)))

    return str(stdout_data, 'utf-8') if stdout_data else None


# Given an array of 1 or more IP addresses, try to SSH to each one and 
# (if any fail) raise an Exception (listing the failed IP addresses)
def validate_ssh(ips, user, SSH_KEY, timeout_secs=10, attempts=1):
    failed = []
    for ip in ips:
        connected = False
        for i in range(attempts):
            try:
                print("Attempting to SSH to %s as %s" % (ip, user))
                execute(['ssh', '-o', 'StrictHostKeyChecking=no', '-o', "ConnectTimeout=%d" % timeout_secs, '-i', SSH_KEY, "%s@%s" % (user, ip), "pwd"])
                print("Connected via SSH to %s as %s" % (ip, user))
                connected = True
                break
            except Exception as e:
                print("Failed to connect via SSH to %s as %s: %s" % (ip, user, e))
                time.sleep(10)
        if connected == False:
            failed.append(ip)
    if len(failed) > 0:
        raise Exception("Failed to SSH to %s as %s" % (", ".join(failed), user))


def get_asg_instances_ips(credentials, asg_name, block_until_running_state=False):
    out = []
    autoscale = boto3.client('autoscaling',
                             aws_access_key_id=credentials['AccessKeyId'],
                             aws_secret_access_key=credentials['SecretAccessKey'],
                             aws_session_token=credentials['SessionToken'],
                             region_name='eu-central-1'
                             )
    ec2 = boto3.resource('ec2',
                         aws_access_key_id=credentials['AccessKeyId'],
                         aws_secret_access_key=credentials['SecretAccessKey'],
                         aws_session_token=credentials['SessionToken'],
                         region_name='eu-central-1')

    # get instance IDs for the defined auto-scaling group
    paginator = autoscale.get_paginator('describe_auto_scaling_groups')
    groups = paginator.paginate(PaginationConfig={'PageSize': 10})
    filtered_asgs = groups.search('AutoScalingGroups[] | [?contains(AutoScalingGroupName, `{}`)]'.format(asg_name))
    asg = next(filtered_asgs)
    instance_ids = [i['InstanceId'] for i in asg['Instances']]
    print("Found instance Ids for ASG %s: %s" % (asg_name, (",").join(instance_ids)))

    # get private IP addresses
    for instance_id in instance_ids:
        ec2instance = ec2.Instance(instance_id)

        state_code = -1
        if block_until_running_state:
            max_iter = 10
            while True:
                state_code = ec2instance.state['Code']
                if state_code == 16 or max_iter == 0:
                    break
                max_iter -= 1
                print("Waiting for instance %s to be in running state..." % instance_id)
                time.sleep(10)

        if state_code == 16 and ec2instance.private_ip_address is not None:
            out.append(ec2instance.private_ip_address)
        else:
            print("Instance %s in ASG %s excluded: state = %s, private ip = %s" % (instance_id, asg_name, state_code, ec2instance.private_ip_address))

    return out


def get_master_nodes_ip_addresses(credentials, git_ssh_key, aws_account_id, layer, re_init=False):
    aug_env = os.environ.copy()
    aug_env['AWS_ACCESS_KEY_ID'] = credentials['AccessKeyId']
    aug_env['AWS_SECRET_ACCESS_KEY'] = credentials['SecretAccessKey']
    aug_env['AWS_SESSION_TOKEN'] = credentials['SessionToken']
    aug_env['TF_VAR_account_id'] = aws_account_id
    aug_env['GIT_SSH_COMMAND'] = 'ssh -i ' + git_ssh_key

    os.chdir("../infra/terraform/layers/%s" % layer)
    if re_init:
        os.chdir("../../")
        execute(['make', 'init'], stdout=sys.stdout, stderr=sys.stderr, env=aug_env)
        os.chdir("layers/%s" % layer)
    airflow_master_asg_name = execute(['terraform', 'output', 'airflow_master_asg_name'], env=aug_env).strip()
    os.chdir('../../../')  # infra

    return get_asg_instances_ips(credentials, airflow_master_asg_name, True)


def get_git_hash():
    return execute(['git', 'rev-parse', '--verify', 'HEAD']).strip()[:8]


def update_report_path_append_report():
    import re
    import xml.etree.ElementTree as ET
    import logging

    try:
        pattern="(Cng_Dag_UnitTests_Template-test_)(.*)(.csv.*)"
        input_xml ="test_case_merge_template.xml"
        csv_key=".csv"
        template_key="Cng_Dag_UnitTests_Template-"


        input_tree =ET.parse(input_xml)
        input_root= input_tree.getroot()

        path=os.path.abspath("../src/test/test-reports/")
        for report in os.listdir(path):
            dag_file_name=None
            suffix=None
            if report.startswith("TEST-Cng_Dag_UnitTests_Template-"):
                #find dag file name
                for match in re.findall(pattern, report):
                    for value in match:
                        if str(value).startswith(csv_key):
                            suffix=value
                        if not (str(value).startswith(template_key) or str(value).startswith(csv_key)):
                            dag_file_name=value

                if dag_file_name is None or suffix is None:
                    raise Exception("parsing error")

                tree =ET.parse(path+"/"+report)
                root= tree.getroot()
                for elem in root.iterfind('testcase'):
                    elem.attrib['classname'] = "dags."+dag_file_name

                    #append errors
                    ele_error=None
                    for ele in elem.iterfind('error'):
                        ele_error=ele
                    if ele_error:
                        ele.append(ele_error)
                    input_root.append(elem)

                #set error count
                errors = int(input_root.get('errors'))+int(root.get('errors'))
                failures = int(input_root.get('failures'))+int(root.get('failures'))
                tests = int(input_root.get('tests'))+int(root.get('tests'))
                input_root.set("errors",str(errors))
                input_root.set("failures",str(failures))
                input_root.set("tests",str(tests))

         #write data to output file
        if int(input_root.get('tests'))>0:
            input_tree.write("report.xml", encoding='utf-8')
            logging.info("xml merge is finished")
        else:
            logging.critical("xml files are  not merged")


    except Exception as e:
        print(e.with_traceback())
        #raise e


