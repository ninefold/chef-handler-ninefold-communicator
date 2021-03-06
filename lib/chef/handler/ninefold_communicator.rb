# Chef Handler for communicating run status via emitted log entries
#
# Author::    Warren Bain <ninefolddev@ninefold.com>
# Copyright:: Copyright Ninefold Pty Limited.
# License::   Reserverd
#

require 'rubygems'
Gem.clear_paths
require 'chef'
require 'chef/log'
require 'chef/handler'

module Ninefold
  module Handler
    class Communicator < ::Chef::Handler

      attr_accessor :options, :ignore, :tag, :marker, :highlight, :state

      def initialize(params)
        log :debug, "initialized with options #{params.to_s}"
        # we do this so that we can pass node attributes which are immutable!
        options    = params.dup || {}
        @tag       = options.delete(:tag)
        @ignore    = options.delete(:ignore) || []
        @marker    = options.delete(:marker)
        @highlight = options.delete(:highlight)
        @state     = options.delete(:state) || {}
        # NOTE: next method is logical but not possible as node object is not available
        # -> set_run_started
        # instead, this is enabled in the cookbook that initialises us
      end

      def report
        unless run_failed?
          log(:debug, "run succeeded")
          set_run_succeeded
        else
          log(:debug, "run failed")
          set_run_failed
          if ignore_exception?(run_exception)
            log(:debug, "ignoring exception: #{run_exception}")
          else
            log(:fatal, exception_copy)
          end
          log(:fatal, marker_copy) if marker
        end
      end

      protected

      def status_copy(type)
        prettify("Your app deployment on #{node.name} #{type}")
      end

      def exception_copy
        prettify(
          "Your app deployment on #{node.name} failed for the following reason:",
          "  ==>  #{formatted_exception}  <==",
          "Please contact Ninefold Support if you require further assistance."
        )
      end

      def marker_copy
        "#{marker}_START #{formatted_exception} #{marker}_END"
      end

      def prettify(*lines)
        log(:debug, "outputting #{lines}")
        repeat = 100
        msg = "#{tag} "
        msg << border(repeat) << "\n" if highlight
        msg << lines.join("\n")
        msg << "\n" << border(repeat) if highlight
        msg
      end

      def log(level, message)
        Chef::Log.send log_level(level), "#{self.class.to_s} #{message}"
      end

      def log_level(level)
        level = level.to_s.to_sym unless level.is_a? Symbol
        level = :info unless [ :info, :debug, :warn, :error, :fatal ].include?(level)
        level
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
        # we remove any timestamps so that logstash doesn't break our lines up...
        exception = run_status.formatted_exception
        if exception
          exception.gsub!(/\[[ :0-9T\/\-\+]+\]\s/,'')
        end
        exception
      end

      def ignore_exception?(exception)
        ignore.any? do |ignore_case|
          ignore_case[:class] == exception.class.name && (!ignore_case.key?(:message) || !!ignore_case[:message].match(exception.message))
        end
      end

      def set_run_started
        # NOTE: here for completeness but not possible to run
        # this on initialisation as node object is not available then
        log(:debug, "setting state to 'run started'")
        set_tags(started_tag)
        unset_tags(succeeded_tag, failed_tag)
        node.save
      end

      def set_run_succeeded
        log(:debug, "setting state to 'run succeeded'")
        set_tags(succeeded_tag)
        unset_tags(failed_tag, started_tag)
        node.save
      end

      def set_run_failed
        log(:debug, "setting state to 'run failed'")
        set_tags(failed_tag)
        unset_tags(succeeded_tag, started_tag)
        node.save
      end

      def set_tags(*tags)
        node.set[:tags] |= tags
      end

      def unset_tags(*tags)
        node.set[:tags] -= tags
      end

      def succeeded_tag
        state[:success] || "Success"
      end

      def failed_tag
        state[:failure] || "Failue"
      end

      def started_tag
        state[:running] || "Running"
      end

      def node
        @node ||= run_status.node
      end

    end
  end
end
