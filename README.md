# jagatku

## Requirements
1. Runs on Apple silicon macos
2. Install kubectl: `brew install kubectl`
3. Install vagrant: `brew install vagrant`
4. Install virtualbox: https://www.virtualbox.org/wiki/Downloads
5. Install ansible: `brew install ansible`

## Initial setup
1. Start vagrant machines: `vagrant up`


## Errors
### undefined method `exists`?
This error happen when using virtualbox version `7.2.6`
```shell
==> default: Attempting graceful shutdown of VM...
==> default: Destroying VM and associated drives...
/usr/share/vagrant/gems/gems/vagrant-vbguest-0.32.0/lib/vagrant-vbguest/hosts/virtualbox.rb:84:in `block in guess_local_iso': undefined method `exists?' for class File (NoMethodError)

path && File.exists?(path)
^^^^^^^^
```
Detail discussion can be found in https://github.com/hashicorp/vagrant/issues/13404, the solution is to use forked plugin repo in https://github.com/dheerapat/vagrant-vbguest?tab=readme-ov-file#vagrant-vbguest
