FROM nitrousio/autoparts-builder

RUN add-apt-repository -y \
    ppa:cassou/emacs
RUN apt-get update; apt-get install -y \
    cron \
    openssh-server \
    screen \
    tree \
    zsh \
    unzip \
    software-properties-common \
    python-software-properties \
    openjdk-7-jdk \
    emacs24 \
    emacs24-el \
    emacs24-common-non-dfsg

# autoparts
RUN parts install \
    maven \
    scala \
    nodejs \
    ruby2.1 \
    chruby \
    heroku_toolbelt \
    # postgresql

# npm
RUN npm install -g \
    bower \
    grunt-cli \
    requirejs \
    less

# scala
ENV PLAY_VERSION 2.2.3
ENV SBT_VERSION 0.13.5
RUN wget http://downloads.typesafe.com/play/$PLAY_VERSION/play-$PLAY_VERSION.zip
RUN unzip play-$PLAY_VERSION.zip
RUN mv play-$PLAY_VERSION /usr/local
RUN wget http://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb
RUN dpkg -i sbt-$SBT_VERSION.deb 
RUN rm -fr play-$PLAY_VERSION.zip sbt-$SBT_VERSION.deb

# dot files
RUN git clone https://github.com/nabinno/dotfiles.git
RUN find ~/dotfiles -maxdepth 1 -mindepth 1 | xargs -i mv -f {} ~/
RUN rm -fr dotfiles .git README.md

# environmental variables
RUN sed -i "s/^#Protocol 2,1/Protocol 2/g" /etc/ssh/sshd_config
RUN sed -i "s/^#SyslogFacility AUTH/SyslogFacility AUTH/g" /etc/ssh/sshd_config
RUN sed -i "s/^\(PermitRootLogin yes\)/#\1\nPermitRootLogin without-password/g" /etc/ssh/sshd_config
RUN sed -i "s/^\(ChallengeResponseAuthentication no\)/#\1\nChallengeResponseAuthentication yes/g" /etc/ssh/sshd_config
# RUN sed -i "s/^\(#PasswordAuthentication yes\)/\1\nPasswordAuthentication yes/g" /etc/ssh/sshd_config
RUN sed -i "s/^\(PATH=.*?\)$/\1\nLANG=en_US.UTF-8/g" /etc/environment
RUN echo 'root:screencast' | chpasswd
RUN echo 'action:nitrousio' | chpasswd
RUN chsh -s /usr/bin/zsh root
RUN chmod 777 /var/run/screen
RUN chmod 777 -R /var/spool/cron
RUN chown -R action:action /home/action

# sshd
RUN mkdir -p /var/run/sshd
EXPOSE 22
CMD    /usr/sbin/sshd -D

