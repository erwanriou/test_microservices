# FUNCTION TO REMOVE HOST IN SHELL SCRIPT
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

remove() {
  HOSTNAME=$1
  if
    [ -n "$(grep $HOSTNAME /etc/hosts)" ];
  then
    echo "$HOSTNAME found in /etc/hosts. Removing now...";
    try sudo sed -ie "/[[:space:]]$HOSTNAME/d" "/etc/hosts";
  else
    yell "$HOSTNAME was not found in /etc/hosts";
  fi
}

# CHECK DOCKER IS INSTALLED
DOCKER_RUNNING=$(docker -v | grep "Docker version" | awk '{ print $2 }')
if
  [ ! "$DOCKER_RUNNING" = "version" ];
then
  echo "$(tput setaf 1)::DOCKER INSTALLATION NEEDED$(tput sgr 0)"
  echo "$(tput setaf 1)::CHECK https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository$(tput sgr 0)"
  exit
fi

# CHECK GCLOUD IS INSTALLED
GCLOUD_RUNNING=$(gcloud -v | grep gsutil | awk '{ print $1 }')
if
  [ ! "$GCLOUD_RUNNING" = "gsutil" ];
then
  echo "$(tput setaf 1)::GCLOUD INSTALLATION NEEDED$(tput sgr 0)"
  echo "$(tput setaf 1)::CHECK https://cloud.google.com/sdk/docs/install$(tput sgr 0)"
  exit
fi

OS=$(uname -s)
if
  [ "$OS" = "Linux" ];
then
  # CHECK IF MINIKUBE IS RUNNING
  MINIKUBE_RUNNING=$(minikube status | grep host | awk '{ print $2 }')
  if
    [ ! "$MINIKUBE_RUNNING" = "Running" ];
  then
    minikube start --kubernetes-version=v1.21.3
    sleep 10s
    echo "$(tput setaf 2)::MINIKUBE NOW RUNNING$(tput sgr 0)"
  else
    echo "$(tput setaf 2)::MINIKUBE ALREADY RUNNING$(tput sgr 0)"
  fi
  echo "$(tput setaf 2)::CLOSING ALL PREVIOUS DEPLOYMENTS$(tput sgr 0)"
  kubectl config use-context minikube
  kubectl -n default delete deployment,pod,services --all
else
  echo "$(tput setaf 2)::CLOSING ALL PREVIOUS DEPLOYMENTS$(tput sgr 0)"
  kubectl config use-context docker-desktop
  kubectl -n default delete deployment,pod,services --all
fi

# FIRST STATE PICK SERVER
echo "$(tput setaf 2)::SELECT THE UI TO LAUNCH$(tput sgr 0)"
echo "  1 - ALL UI"
echo "  2 - ADMIN UI ONLY"
echo "  3 - CLIENT UI ONLY"

read SERVER_OPTION

# CHECK IF ENV LOCAL EXIST
if
  [ ! -f .npmrc ]
then
  # CREATE NEEDED RESSOURCES
  echo -e "registry=https://registry.npmjs.org" > .npmrc
  echo -e "semi: false \ntrailingComma: \"none\" \narrowParens: \"avoid\" \nprintWidth: 150" > .prettierrc.yml
fi

# GET ALL NEEDED REPOSITORIES
case $UPDATE_REPOSITORY in
  y) echo "$(tput setaf 2)::UPDATE ALL REPOSITORIES$(tput sgr 0)" && git fetch && git pull --ff-only && git submodule update --init --recursive -j 8 && git submodule foreach 'git checkout develop' && git submodule foreach 'npm run install:env' && git submodule foreach 'git fetch' && git submodule foreach 'git pull --ff-only';;
  n) echo "$(tput setaf 2)::KEEP ACTUALS VERSIONS OF REPOSITORIES$(tput sgr 0)";;
  *) echo "$(tput setaf 2)::KEEP ACTUALS VERSIONS OF REPOSITORIES$(tput sgr 0)";;
esac

# ENSURE NGINX IS RUNNING
echo "$(tput setaf 2)::CHECK IF INGRESS NGINX IS INSTALLED$(tput sgr 0)"
if
  [ "$OS" = "Linux" ];
then
  NGINX=$(kubectl get pods -n kube-system | grep nginx-ingress-controller | awk '{ print $3 }')
else
  NGINX=$(kubectl get pods -n ingress-nginx | grep ingress-nginx-controller | awk '{ print $3 }')
fi

if
  [ ! "$NGINX" = "Running" ]
then
  # CHECK YOUR LOCAL OS
  echo "$(tput setaf 2)::INSTALLING INGRESS NGINX$(tput setaf 0)"
  case $OS in
    Linux*)     minikube addons enable ingress ;;
    Darwin*)    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.0/deploy/static/provider/cloud/deploy.yaml ;;
    CYGWIN*)    minikube addons enable ingress ;;
    MINGW*)     echo "$(tput setaf 1)Windows not supported$(tput sgr 0)" ;;
    *)          echo "$(tput setaf 1)unknown OS not supported: ${OS}$(tput sgr 0)" ;;
  esac
else
  echo "$(tput setaf 2)::INGRESS NGINX ALREADY INSTALLED AND RUNNING$(tput sgr 0)"
fi

if
  [ "$OS" = "Linux" ];
then
  echo "$(tput setaf 2)::ADD MINIKUBE IP TO ECT/HOST AND SETUP INGRESS CONTROLLER$(tput sgr 0)"
  MINIKUBE_IP=$(minikube ip)
  kubectl expose deployment ingress-nginx-controller --target-port=80 --type=ClusterIP -n kube-system
  # REMOVE OLD ECTHOST VALUES
  remove "booker.dev"

  # ADDING CORRECT ONES
  echo "${MINIKUBE_IP}  booker.dev" | sudo tee -a /etc/hosts
fi

if
  [ "$OS" = "Darwin" ];
then
  LOCALHOST_IP=127.0.0.1
  HOSTNAME="booker.dev"
  if
    [ ! -n "$(grep $HOSTNAME /etc/hosts)" ]
  then
    echo "$(tput setaf 2)::ADD IP TO ECT/HOST$(tput sgr 0)"

    # ADDING CORRECT ONES
    echo "${LOCALHOST_IP}  booker.dev" | sudo tee -a /etc/hosts
  fi
fi

# LAUNCH SKAFFOLD
echo "$(tput setaf 2)::LAUNCHING SKAFFOLD$(tput sgr 0)"
case $SERVER_OPTION in
  1) skaffold dev --filename='infra/skaffold/all.yml';;
  2) skaffold dev --filename='infra/skaffold/admin.yml';;
  3) skaffold dev --filename='infra/skaffold/client.yml';;
  *) exit;;
esac
