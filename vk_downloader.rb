#!/usr/bin/env ruby

require 'vkontakte_api'
require 'net/http'
require 'uri'

VkontakteApi.configure do |config|
  config.app_id     = '4335723'
  config.app_secret = 'DNFgn27cjVZjgAGN3l9o'
end

CODE = ENV['VK_CODE'] || abort("Please visit #{VkontakteApi.authorization_url(scope: [:audio])} first and set VK_CODE environment variable")
USER_ID = ENV['VK_ID'] || abort('Please set VK_ID environment variable to your user id')
SAVE_DIR = './downloaded'

trap('INT') do
  @interrupted = true
end

begin
  @vk = VkontakteApi.authorize(code: CODE)
rescue OAuth2::Error => e
  warn e
  warn VkontakteApi.authorization_url(scope: [:audio])
  abort 'Code expired. Please visit url and update VK_CODE environment variable.'
end

def download_audio(audio)
  file_name = "#{audio.artist} - #{audio.title}.mp3".gsub(%r{[\x00\/\\:\*\?\"<>\|]}, '_')
  puts "Downloading #{file_name}"
  File.open(File.join(SAVE_DIR, file_name), 'w') do |file|
    file.write Net::HTTP.get(URI(audio.url))
  end
end

FileUtils.mkdir_p SAVE_DIR

@vk.audio.get(owner_id: USER_ID).drop(1)
  .each { |audio| download_audio(audio) unless @interrupted  }
