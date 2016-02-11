VMPowerScript - Script to help power on/off VMs in MCP
=============================================================

Overview
========
This script will install the didata_cli python module and its dependencies.  This script is a wrapper around the CLI
and will run only the CLI's poweroff and poweron features.
Information about the CLI can be found here:
https://github.com/DimensionDataDevOps/didata_cli


Dependencies
============
The following dependencies will be automatically installed by the shell script:

- python
- git
- pip
- didata_cli and its dependencies(these are python modules)


Usage
=====

To power on VM(s)
    /bin/bash scripts/didata-power.sh -u username -p password --poweron --nodes serverid_1,serverid_2

To power off VM(s)
    /bin/bash scripts/didata-power.sh -u username -p password --poweroff --nodes serverid_1,serverid_2

serverid will look like this
    9ef6bd45-0d00-4259-a9df-8e396b254dd6

List of nodes passed into the script should be comma separated.

Contributing
============

1. Fork it ( https://github.com/DimensionDataDevOps/VMPowerScript/fork  )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

License
=======

Dimension Data CLI is licensed under the Apache 2.0 license. For more information, please see LICENSE_ file.

.. _LICENSE: https://github.com/DimensionDataDevOps/VMPowerScript/blob/master/LICENSE
