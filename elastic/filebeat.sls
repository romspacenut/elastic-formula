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
{% endif %}

install-filebeat:
  pkg.installed:
    - name: {{ filebeat_settings.pkg_name }}
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