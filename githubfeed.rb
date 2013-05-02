begin
  require 'feedzirra'

  feed = Feedzirra::Feed.fetch_and_parse(ENV['GITHUBFEED'])

  for entry in feed.entries
    author = entry.author || "Someone"
    title = entry.title || "A Commit"
    puts "* #{author.strip}: #{title.strip}"
  end
rescue Exception => e
  puts e
end
