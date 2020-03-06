import os
import sys
from common import execute, get_asg_instances_ips, validate_ssh


#SSH_KEY = os.environ['SSH_KEY']
#GIT_SSH_KEY = os.environ['GIT_SSH_KEY']

AWS_ACCOUNT_ID = "793274344479"
AWS_ROLE = "dev"
LAYER ="LRNTHN"
SLACK_TITLE = "Orchestration-%s-Pipeline" % LAYER
SSH_KEY="tuiuki-cng-dev"
GIT_SSH_KEY="SSH_KEY"
INFRA_ACTION="plan"
SLACK_WEBHOOK="ggg"
os.environ['SLACK_WEBHOOK']="gg"


print("hey infra")
token=os.environ['aws_token']
access_id=  os.environ["access_id"]
secret=os.environ["aws_secret"]
print(token)




if __name__ == "__main__":
    try:


        aug_env = os.environ.copy()
        import json
        #filenamelocal="/var/jenkins_home/assume-role-output_local.json"
        # filenamelocal="/Users/Vishal.Thakur/assume-role-output_local.json"
        #
        # local_file = open(filenamelocal, errors='ignore', mode='r')
        # localdata = json.load(local_file)
        # print(localdata)
        # cred=localdata["Credentials"]
        # access_id=cred["AccessKeyId"]
        # secret=cred["SecretAccessKey"]
        # token=cred["SessionToken"]
        aug_env['AWS_ACCESS_KEY_ID'] =access_id
        aug_env['AWS_SECRET_ACCESS_KEY'] = secret
        aug_env['AWS_SESSION_TOKEN'] =token
        aug_env['TF_VAR_account_id'] = AWS_ACCOUNT_ID
        aug_env['GIT_SSH_COMMAND'] = 'ssh -i ' + GIT_SSH_KEY
        aug_env["LAYER"]=LAYER

        print("=== Terraform %s for %s ===" % (INFRA_ACTION, LAYER))
        owd = os.getcwd()
        os.chdir('../infra/terraform')
        out = execute(['make', INFRA_ACTION], stderr=sys.stderr, env=aug_env)
        os.chdir(owd)
        print(out)



        if LAYER == 'LRNTHN1' or LAYER == 'INT' or LAYER == 'SIT' or LAYER == 'PRD':
            if INFRA_ACTION == 'destroy':
                lb_dns_name = ''
                lb_zone_id = ''
            else:
                owd = os.getcwd()
                os.chdir("../infra/terraform/layers/%s" % LAYER)
                lb_dns_name = execute(['terraform', 'output', 'lb_dns_name'], env=aug_env).strip()
                lb_zone_id = execute(['terraform', 'output', 'lb_zone_id'], env=aug_env).strip()
                os.chdir(owd)

            # run DNS configuration
            aug_env_dns = os.environ.copy()
            aug_env_dns['LAYER'] = "%s-DNS" % LAYER
            aug_env_dns['TF_VAR_dest_record_name'] = lb_dns_name
            aug_env_dns['TF_VAR_dest_zone_id'] = lb_zone_id
            print("=== Terraform %s for %s ===" % (INFRA_ACTION, "%s-DNS" % LAYER))
            owd = os.getcwd()
            os.chdir('../infra/terraform')
            execute(['make', "init"], stdout=sys.stdout, stderr=sys.stderr, env=aug_env_dns)

            execute(['make', INFRA_ACTION], stdout=sys.stdout, stderr=sys.stderr, env=aug_env_dns)
            os.chdir(owd)

        # Run "configAirflow" Ansible playbook
        if INFRA_ACTION == 'apply':
            # extract outputs from the Terraform execution
            owd = os.getcwd()
            os.chdir("../infra/terraform/layers/%s" % LAYER)
            airflow_redis = execute(['terraform', 'output', 'airflow_redis_endpoint_address'], env=aug_env).strip()
            airflow_rds = execute(['terraform', 'output', 'airflow_rds_endpoint'], env=aug_env).strip()
            rds_username = execute(['terraform', 'output', 'rds_username'], env=aug_env).strip()
            rds_password = execute(['terraform', 'output', 'rds_password'], env=aug_env).strip()
            af_ui_password = execute(['terraform', 'output', 'af_ui_password'], env=aug_env).strip()
            airflow_log_group = execute(['terraform', 'output', 'aws_cloudwatch_log_group_name'], env=aug_env).strip()
            airflow_startuplogs_group = execute(['terraform', 'output', 'aws_cloudwatch_startuplogs_group_name'], env=aug_env).strip()
            dd_api_key = execute(['terraform', 'output', 'dd_api_key'], env=aug_env).strip()
            environment_name = execute(['terraform', 'output', 'environment_name'], env=aug_env).strip()
            os.chdir(owd)

            aug_env['AIRFLOW_REDIS'] = airflow_redis
            aug_env['AIRFLOW_RDS'] = airflow_rds
            aug_env['AIRFLOW_RDS_USER'] = rds_username
            aug_env['AIRFLOW_RDS_PASS'] = rds_password
            aug_env['AIRFLOW_UI_PASS'] = af_ui_password
            aug_env['AIRFLOW_LOG_GROUP'] = airflow_log_group
            aug_env['AIRFLOW_STARTUPLOGS_GROUP'] = airflow_startuplogs_group
            aug_env['DD_API_KEY'] = dd_api_key
            aug_env['ENVIRONMENT_NAME'] = environment_name



    except Exception as e:
        print(e)
        raise
