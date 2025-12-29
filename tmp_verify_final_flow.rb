# Setup
u = User.find_or_create_by!(email: "final_tester@example.com") { |x| x.password="password123"; x.username="final_tester" }
song = Song.first || Song.create!(title: "Final Song", artist_name: "Final Artist")
review = Review.create!(user: u, song: song, rating: 5, review_text: "Final Review")

# Clean previous state
Activity.where(actor: u).delete_all
Like.where(user: u).delete_all
Comment.where(user: u).delete_all

puts "--- STEP 1: Like Review ---"
c = Api::V1::LikesController.new
c.instance_variable_set(:@current_user, u)
def c.current_user; @current_user; end
c.params = ActionController::Parameters.new({ likeable_type: "Review", likeable_id: review.id })
def c.render(opts = {}); puts "[[LIKE CREATE]] Status: #{opts[:status]} | JSON: #{opts[:json].to_json}"; end
c.create
like = Like.last

puts "--- STEP 2: Comment on Review ---"
cc = Api::V1::CommentsController.new
cc.instance_variable_set(:@current_user, u)
def cc.current_user; @current_user; end
cc.params = ActionController::Parameters.new({ commentable_type: "Review", commentable_id: review.id, text: "Totally agree!" })
def cc.render(opts = {}); puts "[[COMMENT CREATE]] Status: #{opts[:status]} | JSON: #{opts[:json].to_json}"; end
cc.create

puts "--- STEP 3: View Comments ---"
ci = Api::V1::CommentsController.new
ci.instance_variable_set(:@current_user, u)
def ci.current_user; @current_user; end
ci.params = ActionController::Parameters.new({ review_id: review.id })
# Simulate before_action
ci.instance_variable_set(:@review, review)
def ci.render(opts = {}); puts "[[COMMENT INDEX]] Status: #{opts[:status]} | JSONCount: #{opts[:json].count}"; end
ci.index

puts "--- STEP 4: Unlike ---"
if like
  ld = Api::V1::LikesController.new
  ld.instance_variable_set(:@current_user, u)
  def ld.current_user; @current_user; end
  ld.params = ActionController::Parameters.new({ id: like.id })
  def ld.render(opts = {}); puts "[[LIKE DESTROY]] Status: #{opts[:status]} | JSON: #{opts[:json].to_json}"; end
  ld.destroy
end

puts "--- STEP 5: Verify Activities ---"
acts = Activity.where(actor: u).order(:created_at)
acts.each do |a|
  puts "ACTIVITY: #{a.action_type} on #{a.target_type} #{a.target_id}"
end
