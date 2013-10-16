# Talk with the central tracker
require 'net/http'
require 'thread'

module TrackerClient
  def self.start
    @last_run = {}
    Thread.new do
      run
    end
  end

  def self.on_peer_discovered &block
    @peer_discovered = block
  end

  private
  def self.run
    loop do
      sleep 2
      # FIXME we really need to wait the exact amount of time requested by
      # each tracker
      wait_time = 10
      Shares.each do |share|
        trackers.each do |url|
          poll_tracker share.id, share.peer_id, url

          share.each_code do |code|
            poll_tracker code.id, share.peer_id, url
          end
        end
      end

      PendingCodes.each do |code,path|
        trackers.each do |url|
          poll_tracker code.id, 'FIXME_' + SecureRandom.hex(16), url
        end
      end

      sleep wait_time
    end
  end

  def self.poll_tracker share_id, peer_id, url
    uri = URI(url)
    uri.query = URI.encode_www_form({
      :id => share_id,
      :peer => peer_id,
      :myport => Network.listen_port,
    })
    warn "Tracking with #{uri}"
    res = Net::HTTP.get_response uri
    warn "Tracker said #{res}"
    return unless res.is_a? Net::HTTPSuccess
    info = JSON.parse res.body, symbolize_names: true
    p info

    info[:others].each do |peerspec|
      id, addr = peerspec.split "@"
      # FIXME IPv6 needs better parsing
      ip, port = addr.split ":"
      @peer_discovered.call share_id, id, ip, port.to_i
    end
  end

  def self.trackers
    ["http://localhost:10234/clearskies/track"]
  end


end
