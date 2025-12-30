class UserSerializer < Blueprinter::Base
  identifier :id

  fields :username, :email, :bio, :profile_picture_url

  view :simple do
    only :id, :username, :profile_picture_url
  end
end
