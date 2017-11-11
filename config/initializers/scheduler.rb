require 'rufus/scheduler'

scheduler = Rufus::Scheduler.new

# update weekly trending every 1 hour
scheduler.every '5s' do
  topics = Topic.all
  topics.map do |topic|
    score = 0
    reply_score = 0
    view_score = 0
    replies = topic.replies
    (1..7).each do |day|
      # calculate replies score
      replies.each do |reply|
        if Time.now - reply.created_at < day.send(:days)
          reply_score += 1
        end
      end

      # calculate topic views score
      topic.hit_at.each do |hit|
        if Time.now - Time.parse(hit) < day.send(:days)
          view_score += 1
        end
      end
    end
    score = 3 * reply_score + view_score
    topic.update(weekly_score: score)
  end
end


# update daily trending every 10 minutes
scheduler.every '10m' do
end
