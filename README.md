# flake-module-container

Nix flake containing an example **hello**
[Flask](https://flask.palletsprojects.com/) web app that is deployed in a Nixos
container to test its module definition.

## Running

Creating a NixOS container requires root.

```sh
$ sudo nixos-container create flake-test --flake .
# host IP is 10.233.1.1, container IP is 10.233.10.233

$ sudo nixos-container start flake-test

$ sudo nixos-container root-login flake-test
# [root@nixos:~]

[root@nixos:~] systemctl status hello
# ● hello.service - Hello service
# ...

[root@nixos:~] exit

$ curl http://flake-test:8000/hello
# {"data":"Hello World"}

$ sudo nixos-container destroy flake-test
```

See [Container Management](https://nixos.org/manual/nixos/stable/index.html#ch-containers) in the
NixOS manual.
