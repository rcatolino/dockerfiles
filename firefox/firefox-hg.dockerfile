FROM janitortechnology/ubuntu-dev
MAINTAINER Tim Nguyen "ntim.bugs@gmail.com"

# Install Firefox build dependencies.
# One-line setup command from:
# https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Linux_Prerequisites#Most_Distros_-_One_Line_Bootstrap_Command
RUN sudo apt-get update -q \
 && wget -O /tmp/bootstrap.py https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py \
 && python /tmp/bootstrap.py --no-interactive --application-choice=browser \
 && rm -f /tmp/bootstrap.py

# Download Firefox's source code.
RUN hg clone --uncompressed https://hg.mozilla.org/mozilla-unified/ firefox \
 && cd firefox \
 && hg update central
WORKDIR firefox

# Add Firefox build configuration.
ADD mozconfig /home/user/firefox/
RUN sudo chown user:user /home/user/firefox/mozconfig

# Set up Mercurial extensions for Firefox.
RUN mkdir -p /home/user/.mozbuild \
 && ./mach mercurial-setup -u

# Configure the IDEs to use Firefox's source directory as workspace.
ENV WORKSPACE /home/user/firefox/

# Build Firefox.
RUN ./mach build

# Configure Janitor for Firefox
ADD janitor-hg.json /home/user/janitor.json
RUN sudo chown user:user /home/user/janitor.json
