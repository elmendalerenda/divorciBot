require 'logger'

class AppLogger
  def self.log
    if @logger.nil?
      @logger = Logger.new STDOUT
      @logger.level = Logger::DEBUG
      @logger.datetime_format = '%Y-%m-%d %H:%M:%S '
    end
    @logger
  end

  def self.log=(custom_log)
    @logger=custom_log
  end
end
