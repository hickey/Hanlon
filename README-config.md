Hanlon Configuration File Options
=================================

The following notes attempt to document what configuration settings are 
available and what they control. At this time not all values have been
documented. 


cli/config/hanlon_client.conf
-----------------------------

* noun: config

Always set. Used internally and should not ever be changed. 

* admin_port: 8025

Does not appear to be currently used. 

* api_port: 8026
* api_version: v1
* base_path: "/hanlon/api"
* hanlon_server: '10.2.1.20'

These options define where to locate the API. Note that the api_version 
needs to be supported on the server and be consistent with the server
configuration. The resulting URL to the API would be:

    http://10.2.1.20:8026/hanlon/api/v1/

* hanlon_log_level: Logger::ERROR

Log level setting for CLI commands. Valid values include Logger::UNKNOWN, 
Logger::FATAL, Logger::ERROR, Logger::WARN, Logger::INFO, Logger::DEBUG.

* http_timeout: 60

Time out in seconds for API responses. 

web/config/hanlon_server.conf
-----------------------------

* noun: config

Always set. Used internally and should not ever be changed. 

* admin_port: 8025

Does not appear to be currently used.

* api_port: 8026
* api_version: v1
* base_path: "/hanlon/api"
* hanlon_server: '10.2.1.20'

These options define where the server API is located. The resulting URL 
to receive API requests would be:

    http://10.2.1.20:8026/hanlon/api/v1/

* hanlon_log_level: Logger::ERROR

Log level setting for API requests. Valid values include Logger::UNKNOWN, 
Logger::FATAL, Logger::ERROR, Logger::WARN, Logger::INFO, Logger::DEBUG.

* hanlon_static_path: "/opt/hanlon/static"
* hanlon_subnets: "10.0.0.0/8,172.17.0.0/16"

A list of subnets that hanlon is aware of and will service API requests 
from. If Hanlon is running inside a docker container, then make sure that
the docker0 address (usually within 172.17.0.0/16) is added to the list
of subnets. 

* hnl_mk_boot_debug_level: Logger::ERROR

While this value is set by default to a Ruby logging level, it only
takes effect when the value is set to either 'quiet' or 'debug'. These
values are added to the kernel params for the booting of microkernels. 

* hnl_mk_boot_kernel_args: ''

Additional params to add to the kernel boot line for microkernels. This
setting is useful for setting up the booting/OS output to go to the 
console and the IPMI serial over LAN (SOL) interface. To enable the 
IPMI SOL console, use something similar to the following:

    console=ttyS1,115200n8 console=tty0

* image_path: "/home/hanlon/image"

Location for Hanlon to find and store microkernel and OS images. 
Generally this is used only by Hanlon and does not require any normal
intervention. Note that if Hanlon is running inside a docker container,
then this is the location inside the container and it is advisable
to provide a volume mount to this location so that the images
will survive container restarts. 

* ipmi_password: ''
* ipmi_username: ''
* ipmi_utility: ipmitool

IPMI settings to allow Hanlon node BMC commands to function.

* mk_checkin_interval: 60

How often the microkernel is instructed to check in for commands. 

* mk_log_level: Logger::ERROR

The logging level that the microkernel is instructed to use. Valid values
include Logger::UNKNOWN, Logger::FATAL, Logger::ERROR, Logger::WARN,
Logger::INFO, Logger::DEBUG.

* node_expire_timeout: 300

Time in seconds for a node to be removed from the node database. Although
this does not seem to be actually working. The default is 10 mins. 

* register_timeout: 120

Time in seconds for a node checkin before a re-registration is required.
Default is 2 mins. 

* persist_dbname: project_hanlon
* persist_host: 172.17.0.2
* persist_mode: :mongo
* persist_options_file: ''
* persist_password: ''
* persist_path: "/home/hanlon/data"
* persist_port: 27017
* persist_timeout: 10
* persist_username: ''

These settings configure where Hanlon will persist internal data. At
the moment the persist_mode can be set to :cassandra, :json, :memory,
:mongo and :postgres. The persist_path is only used if the :json mode
is enabled. 



* mk_checkin_skew: 5
* daemon_min_cycle_time: 30
* force_mk_uuid: ''
* hanlon_cifs_share: ''
* sui_allow_access: 'true'
* sui_mount_path: "/docs"

The above settings have not yet been documented. 