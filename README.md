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
1. Problems when using virtualbox as provider.
   ```shell
   ==> default: Attempting graceful shutdown of VM...
   ==> default: Destroying VM and associated drives...
   /usr/share/vagrant/gems/gems/vagrant-vbguest-0.32.0/lib/vagrant-vbguest/hosts/virtualbox.rb:84:in `block in guess_local_iso': undefined method `exists?' for class File (NoMethodError)

   path && File.exists?(path)
   ^^^^^^^^
   ```
   Detail discussion: https://github.com/hashicorp/vagrant/issues/13404
   Solution: https://github.com/dheerapat/vagrant-vbguest?tab=readme-ov-file#vagrant-vbguest
