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
        Chef::Log.debug "#{self.class.to_s} initialized with options #{params.to_s}"
        # we do this so that we can pass node attributes which are immutable!
        options = params.dup || {}
        @tag      = options.delete(:tag)
        @ignore   = options.delete(:ignore) || []
        @options  = options
      end

      def report
        if run_failed?
          Chef::Log.fatal status_copy("failed!")
          unless ignore_exception?(run_exception)
            Chef::Log.fatal exception_copy
          end
        else
          Chef::Log.info status_copy("succeeded!")
        end
      end

      protected

      def status_copy(type)
        prettify("Your app deployment on #{node.name} #{type}")
      end

      def exception_copy
        prettify(
          "We detected that your app deployment on #{node.name} failed for the following reason:",
          "---> #{formatted_exception} <---",
          "Please contact Ninefold Support if you require assistance."
        )
      end

      def prettify(*lines)
        repeat = 25
        msg = tag
        msg << border(repeat) << "\n"
        lines.each do |line|
          msg << "  #{line}\n"
        end
        msg << border(repeat)
      end

      def border(num)
        '-' * num.to_i
      end

      def run_failed?
        run_status.failed?
      end

      def run_information
        run_status.to_hash
      end

      def run_exception
        run_status.exception
      end

      def formatted_exception
        run_status.formatted_exception
      end

      def ignore_exception?(exception)
        ignore.any? do |ignore_case|
          ignore_case[:class] == exception.class.name && (!ignore_case.key?(:message) || !!ignore_case[:message].match(exception.message))
        end
      end
    end
  end
end
