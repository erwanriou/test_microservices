# Booker Infra Repository

## Table of Contents

- [Required](#Required)
- [Pre-installation](#Pre-installation)
- [Installation](#installation)
- [Scripts](#scripts)
- [Production](#production)

## Required

- Nodejs 15+ https://github.com/nodesource/distributions/blob/master/README.md
- Git with stored credentials. Use: `$ git config --global credential.helper store` to save locally before first use. Check with: `$ git config -l`
- Mac or Linux
- Last Chrome/Firefox Version

## Pre-installation

Linux/Ubuntu:

- Install Docker Engine using the repo: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
- Remove sudo from Docker: `sudo setfacl -m user:${USER}:rw /var/run/docker.sock`
- Check Docker is installed: `docker -v`
- Install kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl/
- Install minikube: https://minikube.sigs.k8s.io/docs/start/
- Install skaffold (used for dev environment): https://skaffold.dev/docs/install/
- Install Gcloud SDK (including gutil): https://cloud.google.com/sdk/docs/install

MacOs:

- Install HomeBrew (https://brew.sh/): `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- Install Docker Desktop: https://www.docker.com/products/docker-desktop
- Check Docker is installed: `docker -v` and activate kubernete in docker decktop configs
- Install skaffold (used for dev environment): https://skaffold.dev/docs/install/
- Install Gcloud SDK (including gutil): https://cloud.google.com/sdk/docs/install#mac

## Installation

- Auth with your cloud environment using the Gcloud command: `gcloud auth application-default login`
- Make sure to upload all the secrets needed and apply them to your kubernetes cluster with this command `kubectl create secret generic jwt-secret --from-literal=JWT_TOKEN=somerandomsecretyouneedtoinvent
`
- Fetch submodules with `npm run update`
- Launch with `npm run initiate`
- You can check the installation with `kubectl get pods`.
- Front will not have certificate, you can bypass chrome security with `thisisunsafe`: https://miguelpiedrafita.com/chrome-thisisunsafe or with Firefox: https://timleland.com/firefox-allow-self-signed-certificate/
