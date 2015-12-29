=======
elastic
=======

Formulas to set up and configure the Elastic products.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/conventions/formulas.html>`_.


Dependencies
============

.. note::

   This formula has a dependency on the following salt formulas:

   `java <https://github.com/ministryofjustice/java-formula>`_

   `firewall <https://github.com/ministryofjustice/firewall-formula>`_

Available states
================

.. contents::
    :local:

``init``
----------

Example usage::

    include:
      - elastic.topbeats

Pillar variables
~~~~~~~~~~~~~~~~

- topbeats:default