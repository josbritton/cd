#!/bin/bash

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | DESIRED_VERSION=v4.1.4 bash
runuser -u ubuntu renovate
