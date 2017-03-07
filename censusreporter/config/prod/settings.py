from config.base.settings import *

DEBUG = False
TEMPLATE_DEBUG = DEBUG
ROOT_URLCONF = 'config.prod.urls'
WSGI_APPLICATION = 'config.prod.wsgi.application'
SECURE_PROXY_SSL_HEADER  = ('HTTP_X_FORWARDED_PROTO', 'https')
ALLOWED_HOSTS = [
    '.jlscloud.net',
    '.jlscloud.org',
    '.jlscloud.co',
    '.us-west-2.compute.amazonaws.com',  # allows viewing of instances directly
    'ElasticLo-ElasticL-FGTIONT2WI4F-420622575.us-west-2.elb.amazonaws.com',  # from the load balancer
]

# From https://forums.aws.amazon.com/thread.jspa?messageID=423533:
# "The Elastic Load Balancer HTTP health check will use the instance's internal IP."
# From https://dryan.com/articles/elb-django-allowed-hosts/
import requests
EC2_PRIVATE_IP = None
try:
    EC2_PRIVATE_IP = requests.get('http://169.254.169.254/latest/meta-data/local-ipv4', timeout=0.01).text
except requests.exceptions.RequestException:
    pass

if EC2_PRIVATE_IP:
    ALLOWED_HOSTS.append(EC2_PRIVATE_IP)

CACHES = {
    # django's local in-memory cache
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'unique-snowflake'
    }
    #'default': {
    #    'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
    #    'LOCATION': 'localhost:11211',
    #}

    #'default': {
    #    'BACKEND': 'django.core.cache.backends.dummy.DummyCache',
    #}
}
