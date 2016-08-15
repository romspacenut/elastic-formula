{% from "elastic/logstash/map.jinja" import logstash_settings with context %}

{% if salt['grains.get']('osfullname') == 'Ubuntu' %}
logstash_repo:
  pkgrepo.managed:
    - humanname: Logstash Debian Repository
    - name: {{ logstash_settings.pkgrepo }}
    - file: {{ logstash_settings.file }}
    - gpgcheck: 1
    - key_url: {{ logstash_settings.key_url }}
    - require_in:
      - pkg: {{ logstash_settings.pkg_name }}
    - watch_in:
      - pkg: {{ logstash_settings.pkg_name }}
{%- elif grains['os_family'] == 'RedHat' %}

{%- endif %}

/etc/logstash/conf.d:
  file.directory

{{ logstash_settings.pkg_name }}:
  pkg.installed:
    - name: {{ logstash_settings.pkg_name }}
    - skip_verify: {{ logstash_settings.skip_verify }}
    {% if logstash_settings.version is defined %}
    - version: {{ logstash_settings.version }}
    {% endif %}
  service.running:
    - name: {{ logstash_settings.pkg_name }}
    - enable: True
    - reload: True
    - require:
      - pkg: {{ logstash_settings.pkg_name }}
    - watch:
      - file: /etc/logstash/conf.d*