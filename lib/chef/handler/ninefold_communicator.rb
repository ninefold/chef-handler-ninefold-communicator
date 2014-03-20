# Chef Handler for communicating run statsu via emitted log entries
#
# Author:: Warren Bain <ninefolddev@ninefold.com>
# Copyright:: Copyright 2012 Opscode, Inc.
# License:: Apache2
#

require "chef/handler"

module Ninefold
  class Communicator < ::Chef::Handler

    attr_accessor :options, :ignore, :tag

    def initialize(p)
      puts p
      Chef::Log.debug "#{self.class.to_s} initialized with options #{p.to_s}"
      # we do this so that we can pass node attributes which are immutable!
      options = p.dup || {}
      @tag      = options.delete(:tag)
      @ignore   = options.delete(:ignore) || []
      @options  = options
    end

    def report
      if run_status.failed? && !ignore_exception(run_status.exception)
        Chef::Log.error "#{tag} Reporting exception via Ninefold Communicator"
      else
        Chef::Log.info "#{tag} Reporting success via Ninefold Communicator"
      end
    end

    protected

    def ignore_exception?(exception)
      ignore.any? do |ignore_case|
        ignore_case[:class] == exception.class.name && (!ignore_case.key?(:message) || !!ignore_case[:message].match(exception.message))
      end
    end
  end
end
