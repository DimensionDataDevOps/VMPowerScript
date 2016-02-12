#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

while [[ $# > 0 ]]
do
key="$1"
case $key in
    -n|--nodes)
    nodes="$2"
    shift # past argument
    ;;
    -u|--username)
    username="$2"
    shift # past argument
    ;;
    -p|--password)
    password="$2"
    shift # past argument
    ;;
    --poweron)
    poweron=true
    ;;
    --poweroff)
    poweroff=true
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

get_didata_script(){
    didata=$(which didata)
}

fn_distro(){
  arch=$(uname -m)
  kernel=$(uname -r)
  if [ -f /etc/lsb-release ]; then
    os=$(lsb_release -s -d)
  elif [ -f /etc/debian_version ]; then
    os="Debian $(cat /etc/debian_version)"
  elif [ -f /etc/redhat-release ]; then
    os=`cat /etc/redhat-release`
  else
    os="$(uname -s) $(uname -r)"
  fi
}

yum_install_dependencies(){
    echo "Installing yum dependencies"
    yum install -y python git
}

apt_install_dependencies(){
    echo "Installing apt dependencies"
    apt-get update -y
    apt-get install -y python git
}

install_pip(){
    echo "Installing pip"
    curl -sL https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python ./get-pip.py
}

install_dependencies(){
    if [[ "$os" =~ "Red Hat" ]]; then
       yum_install_dependencies
    elif [[ "$os" =~ "Cent" ]]; then
       yum_install_dependencies
    elif [[ "$os" =~ "Ubuntu" ]]; then
       apt_install_dependencies
    else
       echo "Could not determine OS type"
       exit 1
    fi
    install_pip
    # this line is needed until the PR gets commited into master
    pip install git+https://github.com/apache/libcloud.git@trunk --upgrade
    pip install didata_cli --upgrade
}

create_serverID_array(){
    IFS=',' read -r -a server_ids <<< "$nodes"
}

node_poweron(){
    echo "Powering on server(s)"
    for server in "${server_ids[@]}"; do
        echo "Powering on "$server""
        server_on=$($didata server start --serverId "$server")
        rc=$?
        if [[ $rc != 0 ]]; then
            echo -e "${RED}Problem powering on $server${NC}"
        else
            echo -e "${GREEN}$server_on${NC}"
        fi
    done
}

node_poweroff(){
    echo "Powering off server(s)"
    for server in "${server_ids[@]}"; do
        echo "Powering off "$server""
        server_off=$($didata server shutdown --serverId "$server")
        rc=$?
        if [[ $rc != 0 ]]; then
            echo -e "${RED}Problem powering off $server${NC}"
        else
            echo -e "${GREEN}$server_off${NC}"
        fi
    done
}

check_variables(){
    if [ -z "$nodes" ]; then
        echo "Need to specify a -n|--nodes variable (server ID(s) seperated by commas)"
        exit 1
    fi
    if [[ "$poweron" && "$poweroff" ]]; then
        echo "Need to specify --poweron or --poweroff, not both"
        exit 1
    fi
    if [[ -z "$poweron" ]] && [[ -z "$poweroff" ]]; then
        echo "Need to specify either --poweron or --poweroff"
        exit 1
    fi
    if [ -z "$username" ]; then
        echo "Need to specify a -u|--username variable (Dimension Data Account Username)"
        exit 1
    fi
    if [ -z "$password" ]; then
        echo "Need to specify a -p|--password variable (Dimension Data Account Password)"
        exit 1
    fi
    export DIDATA_USER=$username
    export DIDATA_PASSWORD=$password
}

check_variables
fn_distro

get_didata_script
if [ -z $didata ]; then
    echo "didata not installed, installing all dependencies"
    install_dependencies
fi
get_didata_script
if [ ! -e $didata ]; then
    echo -e "${RED}didata still not installed something has gone wrong${NC}"
    exit 1
fi

create_serverID_array
if [ ! -z $poweron ]; then
    node_poweron
else
    node_poweroff
fi
