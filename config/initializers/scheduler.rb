require 'rufus/scheduler'
require 'topic_score'

include Homeland

scheduler = Rufus::Scheduler.new

redis_config = Rails.application.config_for(:redis)
redis = Redis.new(host: redis_config['host'], port: redis_config['port'])
redis.select(0)

# update weekly trending every 1 hour
scheduler.every '1h' do
  topics = Topic.recent_active_topics(7, :days)
  topics.map do |topic|
    ts = TopicScore.new
    score = ts.score(7, :days, topic)
    topic.update(weekly_score: score)
    redis.del("weekly_trending")
  end
end

# update daily trending every 10 minutes
scheduler.every '10m' do
  topics = Topic.recent_active_topics(24, :hours)
  topics.map do |topic|
    ts = TopicScore.new
    score = ts.score(24, :hours, topic)
    topic.update(daily_score: score)
    redis.del("daily_trending")
  end
end
