
module ChangeMonitor

  # Search for the best available method of monitoring changes
  def find
    begin
      require 'change_monitor/gem_inotify'
      return ChangeMonitor::GemInotify.new
    rescue LoadError
    end

    return nil
  end
end
