# Chef Handler for communicating run status via emitted log entries
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

      attr_accessor :options, :ignore, :tag, :marker, :highlight, :state

      def initialize(params)
        debug "initialized with options #{params.to_s}"
        # we do this so that we can pass node attributes which are immutable!
        options    = params.dup || {}
        @tag       = options.delete(:tag)
        @ignore    = options.delete(:ignore) || []
        @marker    = options.delete(:marker)
        @highlight = options.delete(:highlight)
        @state     = options.delete(:state)
        @options   = options
        # NOTE: we can't do set_run_started here since node is not available
      end

      def report
        unless run_failed?
          debug "run succeeded"
          Chef::Log.info status_copy("succeeded!")
          set_run_succeeded
        else
          debug "run failed"
          set_run_failed
          if ignore_exception?(run_exception)
            Chef::Log.fatal status_copy("failed!")
          else
            debug "formatting exception: #{run_exception}"
            Chef::Log.fatal exception_copy
          end
          debug "outputting marker? #{marker}"
          Chef::Log.fatal marker_copy if marker
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
        debug "outputting #{lines}"
        repeat = 100
        msg = "#{tag} "
        msg << border(repeat) << "\n" if highlight
        msg << lines.join("\n")
        msg << "\n" << border(repeat) if highlight
        msg
      end

      def debug(message)
        Chef::Log.debug "#{self.class.to_s} #{message}"
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
        debug "setting state to run started"
        set_tags(started_tag)
        node.save
      end

      def set_run_succeeded
        debug "setting state to run succeeded"
        set_tags(succeeded_tag)
        unset_tags(failed_tag, started_tag)
        node.save
      end

      def set_run_failed
        debug "setting state to run failed"
        set_tags(failed_tag)
        unset_tags(succeeded_tag, started_tag)
        node.save
      end

      def set_tags(*tags)
        debug "accessing node['tags'] = #{node['tags']}"
        node_tags = node['tags'].dup
        node.set['tags'] = node_tags | tags
      end

      def unset_tags(*tags)
        debug "accessing node['tags'] = #{node['tags']}"
        node_tags = node['tags'].dup
        node.set['tags'] = node_tags - tags
      end

      def succeeded_tag
        state[:success]
      end

      def failed_tag
        state[:failure]
      end

      def started_tag
        state[:running]
      end

    end
  end
end
