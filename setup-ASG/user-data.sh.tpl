#!/bin/bash

apt-get update -y
apt-get install -y wget

CLOUDWATCH_LOG_GROUP_NAME_POSTFIX=asg_dev

wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

systemctl enable amazon-ssm-agent
systemctl start amazon-cloudwatch-agent

cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json <<'JSON'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "aws/asg/${CLOUDWATCH_LOG_GROUP_NAME_POSTFIX}",
            "log_stream_name": "{instance_id}-syslog",
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "${metrics_namespace}",
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent",
          "mem_available",
          "mem_total"
        ],
        "metrics_collection_interval": 60
      },
      "cpu": {
        "measurement": [
          "usage_idle",
          "usage_user",
          "usage_system"
        ],
        "metrics_collection_interval": 60,
        "totalcpu": true
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "resources": ["*"],
        "metrics_collection_interval": 60
      }
    }
  }
}
JSON

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s

systemctl restart amazon-ssm-agent