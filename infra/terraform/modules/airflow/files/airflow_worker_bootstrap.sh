#!/bin/bash
sudo yum -y install wget vim java nfs-utils git awslogs
sudo yum -y erase ntp*
sudo yum -y install unzip chrony
sudo sed -i '7i server 169.254.169.123 prefer iburst' /etc/chrony.conf
sudo systemctl start chronyd
sudo cat /etc/chrony.conf
sudo systemctl enable chronyd

read -d '' PIP_REQS << EOF
${PIP_REQS}
EOF
sudo echo "$PIP_REQS" > /home/ec2-user/requirements.txt
sudo pip3 install -r /home/ec2-user/requirements.txt

read -d '' AF_ENV << EOF
CNG_AIRFLOW_HOME=/home/ec2-user/airflow/
PYTHONPATH=/home/ec2-user/airflow/
CNG_AIRFLOW_ENV=${CODE_ENVIRONMENT}
AIRFLOW_CONN_DATADOG_DEFAULT=${AIRFLOW_CONN_DATADOG_DEFAULT}
METRIC_TAGS=${METRIC_TAGS}
EOF
sudo echo "$AF_ENV" > /etc/sysconfig/airflow
sudo sed -ie '\/var\/log\/messages/,$d' /etc/awslogs/awslogs.conf
sudo sed -i 's/us-east-1/eu-central-1/g' /etc/awslogs/awscli.conf

sudo systemctl stop airflow-worker
sudo systemctl daemon-reload
sudo systemctl restart rsyslog

sudo sed -i 's|After=network.target|After=network.target home-ec2\\x2duser-airflow.mount|g' /usr/lib/systemd/system/airflow-worker.service;

sudo mv /home/ec2-user/airflow /var/tmp/
sudo mkdir -p /home/ec2-user/airflow/
cd /home/ec2-user || exit
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${EFS_ENDPOINT_WORKER}:/ /home/ec2-user/airflow
sudo echo -e "${EFS_ENDPOINT_WORKER}:/ /home/ec2-user/airflow   nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" | sudo tee -a /etc/fstab

sudo mkdir /etc/ssl/private/
sudo openssl req -x509 -nodes -subj "/C=DE/ST=Karl-Wiechert-Allee/L=Hannover/O=TUI/OU=TUID/CN=${ENVIRONMENT}-airflow.aws.tuicloud.net" -days 3650 -newkey rsa:2048 -keyout /etc/ssl/private/airflow-selfsigned.key -out /etc/ssl/certs/airflow-selfsigned.crt
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# Decide whether to copy from local disk (AMI) to EFS volume
copy_to_efs=0
ami_version=$(curl http://169.254.169.254/latest/meta-data/ami-id)
if [[ -f /home/ec2-user/airflow/efs_version ]]; then
  efs_version=`cat /home/ec2-user/airflow/efs_version`
  echo "EFS version: $${efs_version}, AMI version: $${ami_version}"
  copy_to_efs=`expr "$${efs_version}" != $${ami_version}`
else
  echo "No AMI version recorded on EFS, forcing copy from AMI"
  copy_to_efs=1
fi

# Copy from local disk (AMI) to EFS volume
if [ $${copy_to_efs} == 1 ]; then
    echo "Copying incomplete Airflow directory to EFS share, pending configuration by Ansible"
    echo "$${ami_version}" > /var/tmp/airflow/efs_version # Will get copied over to EFS
    sudo rsync -a --delete --force /var/tmp/airflow/ /home/ec2-user/airflow/
    sudo chown -R ec2-user:ec2-user /home/ec2-user/airflow
fi

cd /home/ec2-user || exit
sudo systemctl start airflow-worker

# Run CloudWatch configuration scripts
if [[ -f /home/ec2-user/airflow/cloud.sh ]]; then
  sudo bash /home/ec2-user/airflow/cloud.sh
fi
if [[ -f /home/ec2-user/airflow/startuplogs.sh ]]; then
  sudo bash /home/ec2-user/airflow/startuplogs.sh
fi

touch /home/ec2-user/bootstrap-complete