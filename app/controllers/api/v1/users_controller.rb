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

      # The follow/unfollow logic is now handled in RelationshipsController
      # but we can keep these for V1 compatibility if needed, 
      # though we should lean on the new service.
      def follow
        result = Social::FollowUserService.call(current_user, @user.id)
        if result.success?
          render json: { success: true, message: "Now following user #{@user.id}" }, status: :ok
        else
          render json: { error: result.errors.to_sentence }, status: :unprocessable_entity
        end
      end

      def unfollow
        # Unfollow is simple enough to stay here or have a service. 
        # For now, let's just make it explicit.
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
        render json: @user.following.select(:id, :username, :profile_picture_url), status: :ok
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
