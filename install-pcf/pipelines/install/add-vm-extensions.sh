#!/bin/bash
set -eux
ENV_FILE=env
om --env "${ENV_FILE}" curl --path /api/v0/staged/vm_extensions/web-lb-security-groups -x PUT -d \
            '{"name": "web-lb-security-groups", "cloud_properties": { "security_groups": ["${web_ld_sg}", "${vm_sg}"]}}'

om --env "${ENV_FILE}" curl --path /api/v0/staged/vm_extensions/ssh-lb-security-groups -x PUT -d \
           '{"name": "ssh-lb-security-groups", "cloud_properties": { "security_groups": ["${ssh_ld_sg}", "${vm_sg}"]}}'

om --env "${ENV_FILE}" curl --path /api/v0/staged/vm_extensions/tcp-lb-security-groups -x PUT -d \
            '{"name": "tcp-lb-security-groups", "cloud_properties": { "security_groups": ["${tcp_ld_sg}", "${vm_sg}"]}}'

