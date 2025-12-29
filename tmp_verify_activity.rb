u1 = User.find_or_create_by!(email: "activity_u1@example.com") { |u| u.password="password123"; u.username="act_u1" }
u2 = User.find_or_create_by!(email: "activity_u2@example.com") { |u| u.password="password123"; u.username="act_u2" }
song = Song.first || Song.create!(title: "Activity Song", artist_name: "Activity Artist")

Activity.delete_all
Like.delete_all
Comment.delete_all
Review.delete_all
Follow.delete_all

puts "--- 1. Follow Activity ---"
follow = Follow.create!(follower: u1, following: u2)
act = Activity.last
if act && act.action_type == "followed_user" && act.actor == u1 && act.target == u2
  puts "PASS: Follow Activity Created"
else
  puts "FAIL: Follow Activity: #{act.inspect}"
end

puts "--- 2. Review Activity ---"
review = Review.create!(user: u1, song: song, rating: 5, review_text: "Cool")
act = Activity.last
if act && act.action_type == "reviewed_song" && act.actor == u1 && act.target == song
  # Note: ActivityLoggable for Review sets target to song? Let's check logic.
  # Review log_activity: target = self.try(:likeable) ... || self.try(:song)
  # Yes, Review has :song.
  puts "PASS: Review Activity Created"
else
  puts "FAIL: Review Activity: #{act.inspect}"
end

puts "--- 3. Like Activity (on Review) ---"
like = Like.create!(user: u2, likeable: review)
act = Activity.last
if act && act.action_type == "liked_review" && act.actor == u2 && act.target == review
  puts "PASS: Like Activity Created"
else
  puts "FAIL: Like Activity: #{act.inspect}"
end

puts "--- 4. Comment Activity (on Review) ---"
comment = Comment.create!(user: u2, commentable: review, text: "Agreed!")
act = Activity.last
if act && act.action_type == "commented_on_review" && act.actor == u2 && act.target == review
  # Logic: action_key = "commented_on_#{commentable_type.underscore}" -> "commented_on_review"
  puts "PASS: Comment Activity Created"
else
  puts "FAIL: Comment Activity: #{act.inspect}"
end
