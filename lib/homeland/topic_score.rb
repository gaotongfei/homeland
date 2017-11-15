module Homeland
  class TopicScore
    # ts = TopicScore.new
    # topics = Topic.all
    # ts.score(7, :days, topics)
    def initialize
      @reply_score = 0
      @view_score = 0
      @score = 0
    end

    def score(counts, unit, topic, options={})
      default_options = {start: 1}
      options = default_options.merge(options)
      start = options[:start]
      replies = Topic.recent_replies(topic, counts, unit)
      (start..counts).each do |u|
        replies.each do |reply|
          if Time.now - reply.created_at < u.send(unit.to_sym)
            @reply_score += 1
          end
        end

        topic.hit_at.each do |hit|
          if Time.now - Time.parse(hit) < u.send(unit.to_sym)
            @view_score += 1
          end
        end
      end
      @score = 3 * @reply_score + @view_score
    end

  end
end
