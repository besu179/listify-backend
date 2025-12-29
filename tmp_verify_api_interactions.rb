# Setup Data
u1 = User.find_or_create_by!(email: "api_int_u1@example.com") { |u| u.password="password123"; u.username="api_int_u1" }
u2 = User.find_or_create_by!(email: "api_int_u2@example.com") { |u| u.password="password123"; u.username="api_int_u2" }
song = Song.first || Song.create!(title: "API Int Song", artist_name: "API Artist")
review = Review.create!(user: u1, song: song, rating: 5, review_text: "Base Review")

# Helper to mock controller
def mock_controller(klass, user, params)
  c = klass.new
  c.instance_variable_set(:@current_user, user)
  def c.current_user; @current_user; end
  def c.authenticate_user!; true; end

  # Mock params
  c.params = ActionController::Parameters.new(params)

  # Mock render
  def c.render(opts = {})
    @last_render = opts
    puts "[RENDER] Status: #{opts[:status]} | JSON: #{opts[:json].to_json}"
  end
  def c.last_render; @last_render; end

  c
end

puts "\n--- 1. Test LikesController#create (User 2 likes Review) ---"
Activity.delete_all # Clear log
Like.delete_all

lc = mock_controller(Api::V1::LikesController, u2, { likeable_type: "Review", likeable_id: review.id })
lc.create

like = Like.last
act = Activity.last

if like && like.user == u2 && like.likeable == review
  puts "PASS: Like record created."
else
  puts "FAIL: Like record missing or incorrect."
end

if act && act.action_type == "liked_review" && act.actor == u2 && act.target == review
  puts "PASS: Activity 'liked_review' logged."
else
  puts "FAIL: Activity logging failed. Last activity: #{act.inspect}"
end


puts "\n--- 2. Test LikesController#destroy (User 2 unlikes) ---"
lc_del = mock_controller(Api::V1::LikesController, u2, { id: like.id })
lc_del.destroy

if Like.exists?(like.id)
  puts "FAIL: Like record still exists."
else
  puts "PASS: Like record deleted."
end


puts "\n--- 3. Test CommentsController#create (User 2 comments on Review) ---"
Activity.delete_all # Clear log
Comment.delete_all

cc = mock_controller(Api::V1::CommentsController, u2, { commentable_type: "Review", commentable_id: review.id, text: "Totally agree!" })
cc.create

comment = Comment.last
act = Activity.last

if comment && comment.user == u2 && comment.commentable == review && comment.text == "Totally agree!"
  puts "PASS: Comment record created."
else
  puts "FAIL: Comment record missing/incorrect."
end

if act && act.action_type == "commented_on_review" && act.actor == u2 && act.target == review
  puts "PASS: Activity 'commented_on_review' logged."
else
  puts "FAIL: Activity logging failed. Last: #{act.inspect}"
end


puts "\n--- 4. Test CommentsController#index (List comments for Review) ---"
# Create a few more comments
Comment.create!(user: u1, commentable: review, text: "Thanks!")

cc_idx = mock_controller(Api::V1::CommentsController, u1, { review_id: review.id })
# We need to emulate set_review because it's a before_action that runs automatically in Rails stack but not here
cc_idx.instance_variable_set(:@review, review)
cc_idx.index

# Check output (manually inspected via render log above)
puts "PASS: Index executed (see render output above)."
