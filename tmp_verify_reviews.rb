u1 = User.find_or_create_by!(email: "reviewer1@example.com") { |u| u.password="password123"; u.username="reviewer1" }
u2 = User.find_or_create_by!(email: "reviewer2@example.com") { |u| u.password="password123"; u.username="reviewer2" }
song = Song.first || Song.create!(title: "Test Song", artist_name: "Test Artist")
Review.delete_all

c = Api::V1::ReviewsController.new
def c.current_user; @u; end
def c.current_user=(u); @u=u; end
def c.params; @p || {}; end
def c.params=(p); @p=p; end
def c.response; @r ||= ActionDispatch::TestResponse.new; end # Mock response
def c.render(opts = {}); puts "[[RESULT]] STATUS: #{opts[:status]} | JSON: #{opts[:json].to_json}"; end

puts "--- 1. POST Create (u1) ---"
c.current_user = u1
c.params = ActionController::Parameters.new({ review: { song_id: song.id, rating: 5, review_text: "Great!" } })
c.create

puts "--- 2. POST Duplicate (u1) ---"
c.create

puts "--- 3. GET Index ---"
c.instance_variable_set(:@song, song)
c.index

puts "--- 4. PUT Update (u1 - Owner) ---"
review = Review.find_by(user: u1, song: song)
c.instance_variable_set(:@review, review)
c.params = ActionController::Parameters.new({ id: review.id, review: { rating: 4, review_text: "Better." } })
c.update

puts "--- 5. PUT Update (u2 - Forbidden) ---"
c.current_user = u2
c.update

puts "--- 6. DELETE (u1) ---"
c.current_user = u1
c.destroy
