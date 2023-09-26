FROM debian:11
ARG PROJECT

## Docker Compose Elixir Example
## Using local directory as GIT Repo
## building index at startup
# elixir:
#   build:
#     context: .
#     args:
#       PROJECT: esp8266-rtos-sdk
#   restart: unless-stopped
#   container_name: elixir
#   ports:
#     - '1080:80'
#   volumes:
#     - /mobile/elixir-data:/srv/elixir-data
#     - /home/user/ESP8266_RTOS_SDK/.git:/srv/elixir-data/esp8266-rtos-sdk/repo


RUN \
    : "${PROJECT:?set PROJECT to set the project name}"
RUN echo "CREATING CONTAINER"
RUN \
  apt-get update && \
  apt-get -y install \
    python3 \
    python3-pip \
    python3-jinja2 \
    python3-bsddb3 \
    python3-pytest \
    perl \
    git \
    apache2 \
    libapache2-mod-wsgi-py3 \
    libjansson4 \
    libyaml-0-2 \
    wget

RUN \
  pip3 install falcon

RUN \
  ln -s /usr/bin/pytest-3 /usr/bin/pytest

RUN \
  wget https://bootlin.com/pub/elixir/universal-ctags_0+git20200526-0ubuntu1_amd64.deb

RUN \
  dpkg -i universal-ctags_0+git20200526-0ubuntu1_amd64.deb

RUN \
  wget https://bootlin.com/pub/elixir/Pygments-2.6.1.elixir-py3-none-any.whl

RUN \
  pip3 install Pygments-2.6.1.elixir-py3-none-any.whl

RUN \
  git config --global user.email 'elixir@dummy.com' && \
  git config --global user.name 'elixir'

RUN \
  git clone --single-branch --depth 1 https://github.com/bootlin/elixir.git /usr/local/elixir/

RUN \
  mkdir -p /srv/elixir-data/

ENV LXR_REPO_DIR /srv/elixir-data/$PROJECT/repo
ENV LXR_DATA_DIR /srv/elixir-data/$PROJECT/data
ENV PROJECT $PROJECT

# apache elixir config, see elixir README
# make apache less stricter about cgitb spam headers
RUN echo '\
<Directory /usr/local/elixir/http/> \n\
    Options +ExecCGI \n\
    AllowOverride None \n\
    Require all granted \n\
    SetEnv PYTHONIOENCODING utf-8 \n\
    SetEnv LXR_PROJ_DIR /srv/elixir-data \n\
    SetEnv HOME /var/www \n\
</Directory> \n\
<Directory /usr/local/elixir/api/> \n\
    SetHandler wsgi-script \n\
    Require all granted \n\
    SetEnv PYTHONIOENCODING utf-8 \n\
    SetEnv LXR_PROJ_DIR /srv/elixir-data \n\
    SetEnv HOME /var/www \n\
</Directory> \n\
AddHandler cgi-script .py \n\
<VirtualHost 0.0.0.0:80> \n\
    ServerName localhost \n\
    DocumentRoot /usr/local/elixir/http \n\
    WSGIScriptAlias /api /usr/local/elixir/api/api.py \n\
    AllowEncodedSlashes On \n\
    RewriteEngine on \n\
    RewriteRule "^/$" "/'$PROJECT'/latest/source" [R] \n\
    RewriteRule "^/(?!api|acp).*/(source|ident|search)" "/web.py" [PT] \n\
    RewriteRule "^/acp" "/autocomplete.py" [PT] \n\
</VirtualHost> ' > /etc/apache2/sites-available/000-default.conf

# Fix www-data user
RUN echo '\n\
[user]\n\
	email = elixir@dummy.com\n\
	name = elixir\n\
[safe]\n\
	directory = /srv/elixir-data/'$PROJECT'/repo\n\
' > /var/www/.gitconfig && \
chown www-data:www-data /var/www/.gitconfig

RUN \
  echo -e "\nHttpProtocolOptions Unsafe\nServerName localhost" >> /etc/apache2/apache.conf && \
  a2enmod cgi rewrite

EXPOSE 80
COPY start.sh /start.sh
ENTRYPOINT ["/start.sh"]