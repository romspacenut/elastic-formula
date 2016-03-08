{% from "elastic/filebeat/map.jinja" import filebeat_settings with context %}

{% if salt['grains.get']('osfullname') == 'Ubuntu' %}
filebeat_repo:
  pkgrepo.managed:
    - name: {{ filebeat_settings.pkgrepo }}
    - file: {{ filebeat_settings.file }}
    - gpgcheck: 1
    - key_url: {{ filebeat_settings.key_url }}
    - require_in:
      - pkg: install-filebeat
    - watch_in:
      - pkg: install-filebeat
{%- elif grains['os_family'] == 'RedHat' %}
logstash-repo-key:
  cmd.run:
    - name:  sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
    - unless: rpm -qi gpg-pubkey-d88e42b4-52371eca

logstash-repo:
  pkgrepo.managed:
    - humanname: Elastic Beats Repository
    - baseurl: https://packages.elastic.co/beats/yum/el/$basearch
    - gpgcheck: 1
    - gpgkey: https://packages.elastic.co/GPG-KEY-elasticsearch
    - enabled: 1
    - require:
      - cmd: logstash-repo-key
{%- endif %}

install-filebeat:
  pkg.installed:
    - name: {{ filebeat_settings.pkg_name }}
    - skip_verify: True
    {% if filebeat_settings.version is defined %}
    - version: {{ filebeat_settings.version }}
    {% endif %}

/etc/filebeat/filebeat.yml:
  file.managed:
    - source: salt://elastic/filebeat/filebeat.yml.jinja
    - template: jinja
    - makedirs: True
    - defaults:
      prospectors: {{ filebeat_settings.prospectors }}
      output: {{ filebeat_settings.output }}
      {% if filebeat_settings.shipper is defined %}
      shipper: {{ filebeat_settings.shipper }}
      {% endif %}
      {% if filebeat_settings.logging is defined %}
      logging: {{ filebeat_settings.logging }}
      {% endif %}
  cmd.wait:
    - use_vt: True
    - user: root
    - name: 'su -m -c "service {{ filebeat_settings.pkg_name }} restart 2&>1 >/dev/null"'
    - watch:
      - file: /etc/filebeat/filebeat.yml

{# This seems to hang possiblity because the init script doesn't return properly; cowboy command below until this is fixed #}
#service-filebeat:
#  service.running:
#    - name: {{ filebeat_settings.pkg_name }}
#    - enable: True
#    - reload: True
#    - watch:
#      - file: /etc/filebeat/filebeat.yml

restart-{{ filebeat_settings.pkg_name }}:
  cmd.run:
    - use_vt: True
    - user: root
    - name: 'su -m -c "service {{ filebeat_settings.pkg_name }} restart 2&>1 >/dev/null"'
    - unless: pgrep -f {{ filebeat_settings.pkg_name }}