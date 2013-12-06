# Chef Handler for communicating run status to configured endpoint
#
# Author:: Warren Bain <ninefolddev@ninefold.com>
# Copyright:: Copyright 2012 Opscode, Inc.
# License:: Apache2
#

require "chef/handler"
require "httparty"

class NinefoldCommunicator < Chef::Handler
  VERSION = "0.1.0"

  attr_accessor :options, :ignore, :endpoint

  def initialize(options={})
    @ignore   = options.delete(:ignore) || []
    @endpoint = options.delete(:endpoint) || nil
    @options  = options
  end

  def report
    if run_status.failed? && !ignore_exception(run_status.exception)
      Chef::Log.error "Reporting exception via Ninefold Communicator"
    else
      Chef::Log.info "Reporting success via Ninefold Communicator"
    end

    client_post(server_params)
  end

  def ignore_exception?(exception)
    ignore.any? do |ignore_case|
      ignore_case[:class] == exception.class.name && (!ignore_case.key?(:message) || !!ignore_case[:message].match(exception.message))
    end
  end

  def server_params
    {
      :body => {
        :notifier_name        => "Chef Ninefold Communicator",
        :notifier_version     => VERSION,
        :source               => node.name,
        :params               => {
          :start_time           => run_status.start_time,
          :end_time             => run_status.end_time,
          :elapsed_time         => run_status.elapsed_time,
          :updatedresources     => run_status.updated_resources.count,
          :run_list             => run_status.node.run_list.to_s,
          :exception            => run_status.exception,
          :backtrace            => run_status.backtrace
        }
      }
    }.merge(options)
  end

  def client_post(params)
    HTTParty.post(
      api_server,
      :query => params,
      :headers => { 'Content-Type' => 'application/json' }
    )
  end

  def api_server
    raise ArgumentError.new("You must specify an endpoint url!") unless endpoint
    endpoint
  end

end

