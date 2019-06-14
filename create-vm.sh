#! /bin/bash

usage="Usage: `basename $0` INSTANCE_NAME"
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# == 0 ]; then
  echo -e "\033[0;31mERROR:\033[0m argument INSTANCE_NAMES must be specified."
  echo -e $usage
  exit 1
fi

$THIS_DIR/prepare_venv.sh
source "$THIS_DIR/venv/bin/activate"
python3 "$THIS_DIR/make_startup_script.py"


result=$(gcloud compute instances create $1 \
  --image-family centos-7 \
  --image-project centos-cloud \
  --can-ip-forward \
  --machine-type=f1-micro \
  --network-interface subnet=egress \
  --network-interface subnet=ingress \
  --metadata-from-file startup-script=startup_script.sh)

echo -e "$result"
echo Use $(echo -e "$result" | grep -v NAME | awk '{print substr($5,index($5,",")+1);}'):1080 as SOCKS5 proxy
