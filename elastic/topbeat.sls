{% from "elastic/topbeat/map.jinja" import topbeat_settings with context %}

{% if salt['grains.get']('osfullname') == 'Ubuntu' %}
topbeat_repo:
  pkgrepo.managed:
    - name: {{ topbeat_settings.pkgrepo }}
    - file: {{ topbeat_settings.file }}
    - gpgcheck: 1
    - key_url: {{ topbeat_settings.key_url }}
    - require_in:
      - pkg: install-topbeat
    - watch_in:
      - pkg: install-topbeat
{% endif %}

install-topbeat:
  pkg.installed:
    - name: {{ topbeat_settings.pkg_name }}
    - skip_verify: True
    {% if topbeat_settings.version is defined %}
    - version: {{ topbeat_settings.version }}
    {% endif %}
    
/etc/topbeat/topbeat.yml:
  file.managed:
    - source: salt://elastic/topbeat/topbeat.yml.jinja
    - template: jinja
    - makedirs: True
    - defaults:
      input: {{ topbeat_settings.input }}
      output: {{ topbeat_settings.output }}
      {% if topbeat_settings.shipper is defined %}
      shipper: {{ topbeat_settings.shipper }}
      {% endif %}
      {% if topbeat_settings.logging is defined %}
      logging: {{ topbeat_settings.logging }}
      {% endif %}
  cmd.wait:
    - use_vt: True
    - user: root
    - name: 'su -m -c "service {{ topbeat_settings.pkg_name }} restart"'
    - watch:
      - file: /etc/topbeat/topbeat.yml

{# This seems to hang possiblity because the init script doesn't return properly; cowboy command below until this is fixed #}
#service-topbeat:
#  service.running:
#    - name: {{ topbeat_settings.pkg_name }}
#    - enable: True
#    - reload: True
#    - watch:
#      - pkg: install-topbeat
#      - file: /etc/topbeat/topbeat.yml

restart-{{ topbeat_settings.pkg_name }}:
  cmd.run:
    - use_vt: True
    - user: root
    - name: 'su -m -c "service {{ topbeat_settings.pkg_name }} restart"'
    - unless: pgrep -f {{ topbeat_settings.pkg_name }}