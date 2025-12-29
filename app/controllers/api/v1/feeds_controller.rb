module Api
  module V1
    class FeedsController < ApplicationController
      before_action :authenticate_user!

      # GET /api/v1/feed/following
      def following
        following_ids = current_user.following_ids

        query = Activity.includes(:actor, :target)
                        .where(actor_id: following_ids)

        if params[:before_id].present?
          query = query.where("id < ?", params[:before_id])
        end

        @activities = query.order(created_at: :desc).limit(20)

        render json: format_activities(@activities), status: :ok
      end

      # GET /api/v1/feed/explore
      def explore
        # Simplified explore: recent global activities (excluding current user's own)
        # In a real app, this would be ranked by popularity/activity volume
        query = Activity.includes(:actor, :target)
                        .where.not(actor_id: current_user.id)

        if params[:before_id].present?
          query = query.where("id < ?", params[:before_id])
        end

        @activities = query.order(created_at: :desc).limit(20)

        render json: format_activities(@activities), status: :ok
      end

      private

      def format_activities(activities)
        activities.map do |activity|
          # Filter out activities on private collections not owned by current_user
          if activity.target_type == "Collection"
            col = activity.target
            next if col && !col.public? && col.user_id != current_user.id
          end

          {
            id: activity.id,
            actor: {
              id: activity.actor.id,
              username: activity.actor.username,
              profile_picture_url: activity.actor.profile_picture_url
            },
            action: activity.action_type,
            target: serialize_target(activity),
            created_at: activity.created_at
          }
        end.compact
      end

      def serialize_target(activity)
        target = activity.target
        return nil unless target

        base = { type: activity.target_type, id: target.id }

        case activity.target_type
        when "User"
          base.merge(username: target.username)
        when "Song"
          base.merge(title: target.title, artist_name: target.artist_name)
        when "Review"
          base.merge(rating: target.rating, song_id: target.song_id)
        when "Collection"
          base.merge(title: target.title)
        else
          base
        end
      end
    end
  end
end
