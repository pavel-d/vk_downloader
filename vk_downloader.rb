#!/usr/bin/env ruby

require 'vkontakte_api'
require 'net/http'
require 'uri'

CODE = '92cbe94b8c1bfe525d'
USER_ID = '5720149'
SAVE_DIR = './downloaded'

VkontakteApi.configure do |config|
  config.app_id     = '4335723'
  config.app_secret = 'DNFgn27cjVZjgAGN3l9o'
end

# VkontakteApi.authorization_url(scope: [:notify, :friends, :photos], client_id: 4335723)

trap('INT') { @interrupted = true }

begin
  @vk = VkontakteApi.authorize(code: CODE)
rescue OAuth2::Error => e
  warn e
  warn VkontakteApi.authorization_url(scope: [:audio])
  warn 'Code expired. Please visit url and update CODE in script.'
  exit 1
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