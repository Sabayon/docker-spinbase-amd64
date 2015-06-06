FROM plabedan/gentoo

# Set locales to en_US.UTF-8
RUN echo "en_US.UTF-8 UTF-8 " >> /etc/locale.gen &&  locale-gen &&  eselect locale set en_US.utf8 && env-update && source /etc/profile
ENV LC_ALL=en_US.UTF-8

# Upgrading portage
RUN emerge --sync && layman -a sabayon

# Configure the sabayon box, installing equo setting up locales
ADD ./script/sabayon-configuration.sh /
RUN /bin/bash /sabayon-configuration.sh && rm -rf /sabayon-configuration.sh

# Generating empty equo db
ADD ./script/generate-equo-db.sh /
ADD ./ext/equo.sql /
RUN /bin/bash /generate-equo-db.sh  && rm -rf /equo.sql /generate-equo-db.sh

# Calling equo rescue generate, unfortunately we have to use expect
ADD ./script/equo-rescue-generate.exp /
RUN /usr/bin/expect /equo-rescue-generate.exp &&  rm -rf /equo-rescue-generate.exp

# Portage configurations
ADD ./script/sabayon-configuration-build.sh /sabayon-configuration-build.sh
RUN /bin/bash /sabayon-configuration-build.sh && rm -rf /sabayon-build.sh

# Perform before-upgrade tasks (mirror sorting, updating repository db, removing portage and keeping profiles and metadata)
RUN mv /etc/entropy/repositories.conf.d/entropy_sabayonlinux.org.example /etc/entropy/repositories.conf.d/entropy_sabayonlinux.org && equo up && equo repo mirrorsort sabayonlinux.org && cd /usr/portage/;ls | grep -v 'profiles' | grep -v 'metadata' | xargs rm -rf

# Accepting licenses needed to continue automatic install/upgrade
ADD ./conf/spinbase-licenses /etc/entropy/packages/license.accept

# Upgrading packages
RUN equo u && echo -5 | equo conf update

# Perform post-upgrade tasks (mirror sorting, updating repository db)
ADD ./script/post-upgrade.sh /post-upgrade.sh
RUN /bin/bash /post-upgrade.sh  && rm -rf /post-upgrade.sh
