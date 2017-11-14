require 'rufus/scheduler'
require 'topic_score'

include Homeland

scheduler = Rufus::Scheduler.new

# update weekly trending every 1 hour
scheduler.every '1h' do
  topics = Topic.all
  topics.map do |topic|
    ts = TopicScore.new
    score = ts.score(7, :days, topic)
    topic.update(weekly_score: score)
  end
end

# update daily trending every 10 minutes
scheduler.every '10m' do
  topics = Topic.all
  topics.map do |topic|
    ts = TopicScore.new
    score = ts.score(24, :hours, topic)
    topic.update(daily_score: score)
  end
end
