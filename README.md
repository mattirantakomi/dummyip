# Dummy IP

Creates dummy interface (eg. `dummy0`) on host node with public IP assigned to get Calico node detect correct public IP looked up by this script rather than private IP assigned to virtual machine. Useful when Calico with Wireguard is used on virtual machine behind 1:1 NAT only with private IP address assigned or some public IP to private IP port mappings as Wireguard connectivity requires at least one cluster node to be reachable over internet with public IP.

Launches Apache web server on hostNetwork `0.0.0.0:<port specified>` and checks that public IP -> private IP NAT/port forwarding is working. If test is successful, creates dummy interface and assigns public IP to it and launches `tail -f /dev/null` to keep pod running. If test fails, launches `tail -f /dev/null` to keep pod running.

On 1:1 NAT set `PORT` value to some free port number on host node, forwarded TCP port number when using port forwarding or "`0`" to create dummy interface with public IP assigned without testing connectivity.

Use `Deployment` with `nodeSelector` to run on particular node only. Use `Daemonset` to run on all cluster nodes if every node has own public IP address. Daemonset shouldn't be used if multiple virtual machines are behind the same public IP as Calico node won't tolerate overlapping IP addresses.