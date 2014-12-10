How to Set-up Play framework on Autoparts
=========================================
INDEX
-----
1. Dependencies
2. Set-up Docker/CentOS 6 x86_64
3. Set-up Play2 on Autoparts/Ubuntu 12.04


1. Dependencies
---------------
### servers
- centos = CentOS 6 x86_64
- playonubuntu = Ubuntu 12.04 for Play2 on CentOS 6 x86_64
- client = Client PC

### scripts
- [docker/docker](https://github.com/docker/docker)
- [nitrous-io/autoparts](https://github.com/nitrous-io/autoparts)
- [purcell/emacs.d](https://github.com/purcell/emacs.d)
- [nabinno/dotfiles](https://github.com/nabinno/dotfiles)
- [nabinno/play-on-autoparts](https://github.com/nabinno/play-on-autoparts)
- etc.


2. Set-up Docker/CentOS 6 x86_64
--------------------------------
```sh
root@centos# adduser foo
root@centos# echo foo | passwd bar --stdin

### set env for sudo
root@centos# sed -i "s/^\(root.*\)$/\1\n000\tALL=(ALL)\tALL/g" /etc/sudoers

### set env for auth
root@centos# sed -i "s/^\(#PermitRootLogin yes\)/\1\nPermitRootLogin no/g" /etc/ssh/sshd_config
root@centos# sed -i "s/^\(#PasswordAuthentication yes\)/\1\nPasswordAuthentication no/g" /etc/ssh/sshd_config
root@centos# sed -i "s/^\(#ChallengeResponseAuthentication yes\)/\1\nChallengeResponseAuthentication no/g" /etc/ssh/sshd_config
root@centos# sed -i "s/^\(#RhostsRSAAuthentication no\)/\1\nRhostsRSAAuthentication no/g" /etc/ssh/sshd_config
root@centos# sed -i "s/^\(#PermitEmptyPasswords no\)/\1\nPermitEmptyPasswords no/g" /etc/ssh/sshd_config

### set env for other
root@centos# sed -i "s/^\(#Protocol 2,1\)/\1\nProtocol 2/g" /etc/ssh/sshd_config
root@centos# sed -i "s/^\(#SyslogFacility AUTH\)/\1\nSyslogFacility AUTHPRIV/g" /etc/ssh/sshd_config

### install docker
root@centos# yum install docker-io -y
root@centos# service docker start
root@centos# chkconfig docker on
foo@centos% alias docker='sudo docker'

### set env for auth of password
client# ssh-keygen -t rsa
client# ssh-copy-id -i ~/.ssh/id_rsa.pub foo@centos.host
client# mv ~/.ssh/id_rsa ~/.ssh/id_rsa_foo@centos
client# ssh foo@centos.host
foo@centos% sudo sed -i "s/^\(#PasswordAuthentication yes\)/\1\nPasswordAuthentication no/g" /etc/ssh/sshd_config
foo@centos% sudo /etc/init.d/sshd restart
```


3. Set-up Play framework on Autoparts/Ubuntu 12.04
--------------------------------------------------
```sh
### build
foo@centos% docker build -t nitrousio/autoparts-builder https://raw.githubusercontent.com/nitrous-io/autoparts/master/Dockerfile
foo@centos% docker build -t nabinno/play-on-autoparts https://raw.githubusercontent.com/nabinno/play-on-autoparts/master/Dockerfile

### start sshd server
foo@centos% docker run -t -d -p 30000:3000 -P nabinno/play-on-autoparts /usr/sbin/sshd -D

### get port-playonubuntu
foo@centos% docker inspect --format {{.NetworkSettings.IPAddress}} $(docker ps -l -q)
foo@centos% docker inspect --format {{.NetworkSettings.Ports}} $(docker ps -l -q)

### change password of ubuntu user
client# ssh-keygen -t rsa
client# ssh-copy-id -i ~/.ssh/id_rsa.pub action@playonubuntu -p port-playonubuntu
client# mv ~/.ssh/id_rsa ~/.ssh/id_rsa_action@playonubuntu
client# ssh -t action@playonubuntu(centos.host) zsh -p port-playonubuntu
action@playonubuntu# sudo sed -i "s/^\(#PasswordAuthentication yes\)/\1\nPasswordAuthentication no/g" /etc/ssh/sshd_config
action@playonubuntu# echo 'action:baz' | sudo chpasswd
foo@centos% docker commit $(docker ps -l -q) container_id
```


EPILOGUE
--------
>     A whale! 
>     Down it goes, and more, and more
>     Up goes its tail!
>     
>     -Buson Yosa
