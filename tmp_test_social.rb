u1 = User.find_by(email: 'testuser@example.com')
u2 = User.find_by(email: 'anotheruser@example.com')
controller = Api::V1::UsersController.new

def controller.tester=(u); @tester = u; end
def controller.current_user; @tester; end
controller.tester = u1

def controller.render(json: nil, status: 200)
  puts "[RESULT] Status: #{status || 200}, JSON: #{json.to_json}"
end

puts '--- Testing GET /me ---'
controller.me

puts '--- Testing POST /follow ---'
controller.params = { id: u2.id }
controller.follow

puts '--- Testing GET /followers of User 2 ---'
controller.params = { id: u2.id }
controller.followers

puts '--- Testing DELETE /unfollow ---'
controller.params = { id: u2.id }
controller.unfollow
