# ninefold communicator gem

Chef report handler for emitting formatted messages into the
log for interception via log tags in elasticsearch.

This allos the Ninefold UI and CLI to provide better customer
feedback on what is happening with the app deployment

# Usage

See the ninefold\_handlers cookbook for specific recipe that
drops this guy into the right place for chef to enable it.

    include_recipe 'ninefold_handlers::ninefold_communicator'

# Options

The recipe registers the handler and passes in attributes in

    node['ninefold_handlers']['ninefold_communicator']['arguments']

where arguments are:

* tag    - will be prepended to log messages for interception by consumers
* ignore - array of exceptions that should not get detailed reporting
* marker - special marker in log for nagios to pull out exceptions

# Author

Author:: Warren Bain (warren@ninefold.com)
