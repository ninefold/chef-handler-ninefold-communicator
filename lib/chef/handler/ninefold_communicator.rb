# Chef Handler for communicating run statsu via emitted log entries
#
# Author:: Warren Bain <ninefolddev@ninefold.com>
# Copyright:: Copyright 2012 Opscode, Inc.
# License:: Apache2
#

require 'rubygems'
Gem.clear_paths
require 'chef'
require 'chef/log'
require 'chef/handler'

module Ninefold
  module Handler
    class Communicator < ::Chef::Handler

      attr_accessor :options, :ignore, :tag

      def initialize(params)
        puts params
        Chef::Log.debug "#{self.class.to_s} initialized with options #{params.to_s}"
        # we do this so that we can pass node attributes which are immutable!
        options = params.dup || {}
        @tag      = options.delete(:tag)
        @ignore   = options.delete(:ignore) || []
        @options  = options
      end

      def report
        if run_failed? && !ignore_exception(run_exception)
          # we report the formatted exception with a checkpoint so that
          # Portal can extract it and report to customer via UI / CLI
          msg = tag
          msg << " We detected that your chef run on #{node.name} failed for the following reason:\n"
          msg << " #{formatted_exception}\n"
          msg << " Please contact Ninefold Support if you require further assistance\n"
          Chef::Log.fatal msg
        else
          Chef::Log.info "#{tag} Your chef run on #{node.name} succeeded!"
        end
        Chef::Log.debug run_information
      end

      protected

      def run_failed?
        run_status.failed?
      end

      def run_exception
        run_status.exception
      end

      def formatted_exception
        run_status.formatted_exception
      end

      def run_information
        run_status.to_hash
      end

      def ignore_exception?(exception)
        ignore.any? do |ignore_case|
          ignore_case[:class] == exception.class.name && (!ignore_case.key?(:message) || !!ignore_case[:message].match(exception.message))
        end
      end
    end
  end
end
