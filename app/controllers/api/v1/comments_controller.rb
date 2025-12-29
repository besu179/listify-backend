module Api
  module V1
    class CommentsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_review, only: [ :index ]

      # POST /api/v1/comments
      def create
        commentable = find_commentable
        return unless commentable

        comment = current_user.comments.build(commentable: commentable, text: params[:text])

        if comment.save
          render json: comment, status: :created
        else
          render json: { error: comment.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/reviews/:review_id/comments
      def index
        comments = @review.comments.includes(:user).order(created_at: :desc)
        render json: comments, include: { user: { only: [ :id, :username, :profile_picture_url ] } }, status: :ok
      end

      private

      def find_commentable
        # For now only Reviews, but designed for polymorphism
        params[:commentable_type].constantize.find(params[:commentable_id])
      rescue NameError, ActiveRecord::RecordNotFound
        render json: { error: "Target not found" }, status: :not_found
        nil
      end

      def set_review
        @review = Review.find(params[:review_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Review not found" }, status: :not_found
      end
    end
  end
end
