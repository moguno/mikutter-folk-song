# -*- coding: utf-8 -*-
# Rest API で定期的にタイムラインを更新するプラグイン

Plugin.create :rest do

  def self.define_periodical_executer(api, interval, count, &success)
    counter = UserConfig[interval]
    lambda{ |service|
      counter += 1
      if counter >= UserConfig[interval]
        counter = 0
        service.call_api(api, count: UserConfig[count]){ |messages|
          success.call(service, messages) if messages and not messages.empty? } end } end

  @crawlers = [lambda{ |service| Plugin.call(:period, service) }]
  @crawlers << define_periodical_executer(:friends_timeline, :retrieve_interval_friendtl, :retrieve_count_friendtl) do |service, messages|
    Plugin.call(:update, service, messages)
    Plugin.call(:mention, service, messages.select{ |m| m.to_me? })
    Plugin.call(:mypost, service, messages.select{ |m| m.from_me? }) end
  @crawlers << define_periodical_executer(:replies, :retrieve_interval_mention, :retrieve_count_mention) do |service, messages|
    Plugin.call(:update, service, messages)
    Plugin.call(:mention, service, messages)
    Plugin.call(:mypost, service, messages.select{ |m| m.from_me? }) end

  def start
    if Service.instances.empty?
      @account_observer ||= on_service_registered do |s|
        start
        @account_observer.detach
        @account_observer = nil end
    else
      Service.instances.each { |service|
        @crawlers.each{ |s| s.call(service) } }
      ::Reserver.new(60){
        start } end end

  Delayer.new{ start }
end
