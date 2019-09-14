#!/bin/sh

config_file="deployment/.env";
config_name="config-football-results-api"
kube_file="deployment/kubernetes.yml"

echo "[Kube] Creating a config file"
if [ -f $config_file ]; then
    echo "[Kube] Reading from $config_file";
else
    echo "[Kube] File not found in $config_file.\n[Kube] Using the example from ${config_file}.example";
    cp ./deployment/.env.example ./deployment/.env
fi;

kubectl get configmap $config_name &> /dev/null

if [ $? -eq 1 ]; then
    trap $?
    echo "[Kube] Creating a new config map: $config_name";
    kubectl create configmap $config_name --from-env-file $config_file
else
    echo "[Kube] Updating config map: $config_name";    
    kubectl create configmap $config_name --from-env-file $config_file --dry-run -o yaml | kubectl replace $config_name -f -
fi

echo "[Kube] Applying changes on the server"
kubectl apply -f $kube_file
