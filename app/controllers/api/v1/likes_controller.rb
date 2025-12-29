module Api
  module V1
    class LikesController < ApplicationController
      before_action :authenticate_user!

      # POST /api/v1/likes
      def create
        likeable = find_likeable
        return unless likeable

        like = current_user.likes.build(likeable: likeable)

        if like.save
          render json: like, status: :created
        else
          render json: { error: like.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/likes/:id
      def destroy
        like = current_user.likes.find(params[:id])
        like.destroy
        render json: { message: "Unliked successfully" }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Like not found or not authorized" }, status: :not_found
      end

      private

      def find_likeable
        params[:likeable_type].constantize.find(params[:likeable_id])
      rescue NameError, ActiveRecord::RecordNotFound
        render json: { error: "Target not found" }, status: :not_found
        nil
      end
    end
  end
end
