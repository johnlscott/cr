#!/bin/bash
#git clone https://github.com/johnlscott/cr.git /home/ubuntu/cr
apt-get update
apt-get install -y gunicorn nginx python-dev libxml2 libxslt1-dev git-core python-pip
cd /home/ubuntu/cr
pip install -r requirements.txt
pip install futures
chown -R www-data:www-data /home/ubuntu/cr

cat > /etc/systemd/system/gunicorn.service <<EOL
[Unit]
Description=Gunicorn application server running Django app
After=network.target
After=syslog.target

[Service]
User=www-data
Group=www-data
Environment=PATH=/home/ubuntu/cr/censusreporter/bin
Environment=PYTHONPATH=/home/ubuntu/cr/censusreporter:/home/ubuntu/cr/censusreporter/apps
Environment=DJANGO_SETTINGS_MODULE=config.dev.settings
RuntimeDirectoryMode=755
ExecStart=/usr/bin/gunicorn --chdir /home/ubuntu/cr --threads 3 --bind unix:/home/ubuntu/cr/censusreporter.sock -m 007 config.dev.wsgi
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOL

systemctl enable gunicorn.service
systemctl daemon-reload
systemctl start gunicorn.service
systemctl status gunicorn.service

cat > /etc/nginx/sites-available/censusreporter <<EOL
server {
    listen 80;
    server_name censusreporter.jlscloud.net;

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/ubuntu/cr/censusreporter.sock;
    }

    location /static {
        alias /home/ubuntu/cr/censusreporter/apps/census/static;
    }

    access_log /var/log/nginx/census_reporter.access.log;
    error_log /var/log/nginx/census_reporters.error.log;
}
EOL

ln -s /etc/nginx/sites-available/censusreporter /etc/nginx/sites-enabled/censusreporter
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
systemctl restart nginx
