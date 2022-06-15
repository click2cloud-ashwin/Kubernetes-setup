### A. Kubernetes Setup
1. Prepare lab machine, the preferred OS is **Ubuntu 18.04**.

   If you are using AWS, the recommended instance size is ```t2.xlarge``` and the storage size is ```128GB``` or more.

   If you are using OnPrem, the recommended instance size is ```8 CPU```, ```16GB RAM``` and the storage size is ```100GB``` or more.


```bash
wget https://raw.githubusercontent.com/click2cloud-team3/Kubernetes-setup/master/k8s-setup.sh
sudo bash k8s-setup.sh
```
The lab machine will be rebooted once when above script is completed, you will be automatically logged out of the lab machine.

#### Disable swap:

```bash
sudo swapoff -a
```

### B. Run kubernetes cluster

```bash 
sudo kubeadm init --apiserver-advertise-address=$(hostname -i)
```
kubeadm init first runs a series of prechecks to ensure that the machine is ready to run Kubernetes. These prechecks expose warnings and exit on errors. kubeadm init then downloads and installs the cluster control plane components. This may take several minutes. After it finishes you should see:

#### Output:

```bash
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a Pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  /docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join <control-plane-host>:<control-plane-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

To make kubectl work for your non-root user, run these commands, which are also part of the kubeadm init output:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Alternatively, if you are the root user, you can run:

```bash
export KUBECONFIG=/etc/kubernetes/admin.conf
```

### C. Deploy Calico as CNI

```bash
kubectl apply -f kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

Note: On single node, to schedule pod you need to run the following command to remove taint.

```bash
kubectl taint nodes $(hostname) node-role.kubernetes.io/master:NoSchedule-
```
Output:

```bash
node/master untainted
```
Now your single node kubernetes cluster is ready to use.

