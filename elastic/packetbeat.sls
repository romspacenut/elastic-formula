{% from "elastic/packetbeat/map.jinja" import packetbeat_settings with context %}

{% if salt['grains.get']('osfullname') == 'Ubuntu' %}
packetbeat_repo:
  pkgrepo.managed:
    - name: {{ packetbeat_settings.pkgrepo }}
    - file: {{ packetbeat_settings.file }}
    - gpgcheck: 1
    - key_url: {{ packetbeat_settings.key_url }}
    - require_in:
      - pkg: install-packetbeat
    - watch_in:
      - pkg: install-packetbeat
{% endif %}

install-packetbeat:
  pkg.installed:
    - name: {{ packetbeat_settings.pkg_name }}
    {% if packetbeat_settings.version is defined %}
    - version: {{ packetbeat_settings.version }}
    {% endif %}

/etc/packetbeat/packetbeat.yml:
  file.managed:
    - source: salt://elastic/packetbeat/packetbeat.yml.jinja
    - template: jinja
    - makedirs: True
    - defaults:
      interfaces: {{ packetbeat_settings.interfaces }}
      protocols: {{ packetbeat_settings.protocols }}
      output: {{ packetbeat_settings.output }}
      {% if packetbeat_settings.shipper is defined %}
      shipper: {{ packetbeat_settings.shipper }}
      {% endif %}
      {% if packetbeat_settings.logging is defined %}
      logging: {{ packetbeat_settings.logging }}
      {% endif %}
  cmd.wait:
    - use_vt: True
    - name: 'su -m -c "service {{ packetbeat_settings.pkg_name }} restart"'
    - watch:
      - file: /etc/packetbeat/packetbeat.yml

{# This seems to hang possiblity because the init script doesn't return properly; cowboy command below until this is fixed #}
#service-packetbeat:
#  service.running:
#    - name: {{ packetbeat_settings.pkg_name }}
#    - enable: True
#    - reload: True
#    - watch:
#      - pkg: install-packetbeat
#     - file: /etc/packetbeat/packetbeat.yml

start-{{ packetbeat_settings.pkg_name }}:
  cmd.run:
    - use_vt: True
    - name: 'su -m -c "service {{ packetbeat_settings.pkg_name }} start"'
    - unless: pgrep -f {{ packetbeat_settings.pkg_name }}