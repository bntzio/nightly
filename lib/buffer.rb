require "rest_client"
require_relative "./core_ext/string"

class Buffer
  def self.endpoint action
    "https://api.bufferapp.com/1/#{action}.json?access_token=#{ENV["BUFFER_TOKEN"]}"
  end

  attr_reader :profile, :languages, :tags, :repos
  def initialize profile, languages, tags=""
    @profile = profile
    @languages = Array languages
    @repos = []
    @tags = tags
  end

  def injest some
    Array(some).each do |repo|
      next if repos.include?(repo)
      next if !languages.include?(repo.language)
      next if !repo.english?
      repos.push repo
    end
  end

  def queue
    repos.each do |repo|
      begin
        RestClient.post Buffer.endpoint("updates/create"), {
          "text" => repo.description.twitterized(tags),
          "media[link]" => repo.html_url,
          "profile_ids[]" => profile
        }
      rescue RestClient::BadRequest
        # next plz
      end
    end
  end
end
