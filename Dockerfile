FROM        ubuntu:16.04
MAINTAINER  archoiym@gmail.com

COPY        . /srv/app
RUN         apt-get -y update && \
            apt-get -y install python3 && \
            apt-get -y install python3-pip && \
            apt-get -y install nginx && \
            apt-get -y install supervisor

WORKDIR     /srv/app
RUN         pip3 install -r requirements.txt && \
            pip3 install uwsgi

RUN         apt-get -y install curl && \
            curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
            apt-get -y install nodejs
COPY        . /srv/app
WORKDIR     /srv/app/front
RUN         npm install && \
            npm run build

COPY        .conf/uwsgi-app.ini /etc/uwsgi/sites/app.ini
COPY        .conf/nginx-app.conf /etc/nginx/sites-available/app
COPY        .conf/nginx.conf /etc/nginx/nginx.conf
COPY        .conf/supervisor-app.conf /etc/supervisor/conf.d/
RUN         ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled/app

WORKDIR     /srv/app/django_app
EXPOSE      4567
CMD ["supervisord", "-n"]