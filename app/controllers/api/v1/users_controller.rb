module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!

      before_action :set_user, only: [ :follow, :unfollow, :followers, :following ]

      def me
        render json: {
          user: {
            id: current_user.id,
            username: current_user.username,
            email: current_user.email,
            bio: current_user.bio,
            profile_picture_url: current_user.profile_picture_url
          }
        }
      end

      def follow
        follow = current_user.active_follows.build(following_id: @user.id)
        if follow.save
          render json: { success: true, message: "Now following user #{@user.id}" }, status: :ok
        else
          render json: { error: follow.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end

      def unfollow
        follow = current_user.active_follows.find_by(following_id: @user.id)
        if follow&.destroy
          render json: { success: true, message: "Unfollowed user #{@user.id}" }, status: :ok
        else
          render json: { error: "You are not following this user" }, status: :unprocessable_entity
        end
      end

      def followers
        render json: @user.followers.select(:id, :username, :profile_picture_url), status: :ok
      end

      def following
        render json: @user.followings.select(:id, :username, :profile_picture_url), status: :ok
      end

      private

      def set_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
      end
    end
  end
end
