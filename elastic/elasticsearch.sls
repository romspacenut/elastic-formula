{% from "elastic/elasticsearch/map.jinja" import elasticsearch_settings with context %}
{% from "elastic/elasticsearch/plugin.jinja" import install_plugin %}

{% if salt['grains.get']('osfullname') == 'Ubuntu' %}
elasticsearch_repo:
  pkgrepo.managed:
    - name: {{ elasticsearch_settings.pkgrepo }}
    - file: {{ elasticsearch_settings.file }}
    - gpgcheck: 1
    - key_url: {{ elasticsearch_settings.key_url }}
    - require_in:
      - pkg: install-elasticsearch
    - watch_in:
      - pkg: install-elasticsearch
{%- elif grains['os_family'] == 'RedHat' %}
#logstash-repo-key:
#  cmd.run:
#    - name:  sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
#    - unless: rpm -qi gpg-pubkey-d88e42b4-52371eca

#logstash-repo:
#  pkgrepo.managed:
#    - humanname: Elastic Beats Repository
#    - baseurl: https://packages.elastic.co/beats/yum/el/$basearch
#    - gpgcheck: 1
#    - gpgkey: https://packages.elastic.co/GPG-KEY-elasticsearch
#    - enabled: 1
#    - require:
#      - cmd: logstash-repo-key
{%- endif %}

install-elasticsearch:
  pkg.installed:
    - name: {{ elasticsearch_settings.pkg_name }}
    - skip_verify: True
    {% if elasticsearch_settings.version is defined %}
    - version: {{ elasticsearch_settings.version }}
    {% endif %}
  service.running:
    - name: {{ elasticsearch_settings.service_name }}
    - enable: True
    - watch:
      - pkg: {{ elasticsearch_settings.pkg_name }}
      - file: /etc/elasticsearch/elasticsearch.yml
      - file: /etc/default/elasticsearch

/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - source: salt://elastic/elasticsearch/elasticsearch.yml.jinja
    - template: jinja
    - makedirs: True

/etc/default/elasticsearch:
  file.managed:
    - source: salt://elastic/elasticsearch/elasticsearch
    - template: jinja
    - mode: 640
    - owner: root
    - group: root

# Install plugins
{%- if elasticsearch_settings.plugin is iterable %}
{%- for pkg, repo in elasticsearch_settings.plugin.items() %}
    {{ install_plugin(pkg, repo) }}
{%- endfor %}
{%- endif %}