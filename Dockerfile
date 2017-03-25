FROM sabayon/base-amd64

MAINTAINER mudler <mudler@sabayonlinux.org>

# Set locales to en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
# Accept all licenses
ENV ACCEPT_LICENSE=*

# Upgrading packages and perform post-upgrade tasks (mirror sorting, updating repository db)
ADD ./script/post-upgrade.sh /post-upgrade.sh

RUN equo up && equo u && \
	echo -5 | equo conf update

RUN /bin/bash /post-upgrade.sh  && \
	rm -rf /post-upgrade.sh

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["bash"]
