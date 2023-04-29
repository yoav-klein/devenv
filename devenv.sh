#!/bin/bash


## Configure vim for convinience
cp -r vim/.vim vim/.vimrc ~


## configure git
git config --global user.name "Yoav Klein"
git config --global user.email yoavklein25@gmail.com

if [ ! -f ~/.git_askpass ]; then
    read -p "Enter GitHub token: " github_token
    echo "echo $github_token" > ~/.git_askpass
fi
chmod +x ~/.git_askpass

## add git_askpass to bashrc
if ! grep "GIT_ASKPASS=~/.git_askpass" ~/.bashrc >/dev/null; then
    echo "export GIT_ASKPASS=~/.git_askpass" >> ~/.bashrc
    export GIT_ASKPASS=~/.git_askpass
fi

read -p "Install kubectl addons? (kubens, kubectx..) Y/N" confirm
if [ "$confirm" != "Y" ]; then
    return
fi

## install kubens and kubectx
if [ ! -d /opt/kubectx ]; then
    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
fi

## install kube-ps1
if [ ! -d /opt/kube-ps1 ]; then
    sudo git clone https://github.com/jonmosco/kube-ps1 /opt/kube-ps1
fi

# If running in EKS, context name is long. we can shorten it.
read -p "Running in EKS? Y/N" confirm
if [ "$confirm" = "Y" ] && ! grep "short_context" ~/.bashrc >/dev/null; then
cat <<EOF >> ~/.bashrc
function short_context() {
    echo "\$1" | cut -d / -f 2
}
EOF
echo "KUBE_PS1_CLUSTER_FUNCTION=short_context" >> ~/.bashrc
fi


if ! grep "source /opt/kube-ps1/kube-ps1.sh" ~/.bashrc >/dev/null; then
    echo "source /opt/kube-ps1/kube-ps1.sh" >> ~/.bashrc
    echo "PS1='[\u@\h \W \$(kube_ps1)]\$ '" >> ~/.bashrc
fi
