module Api
  module V1
    class SongsController < ApplicationController
      before_action :authenticate_user!

      def index
        songs = Song.includes(:album).all
        render json: songs, include: { album: { only: [ :id, :title, :cover_url ] } }, status: :ok
      end

      def show
        song = Song.find(params[:id])
        render json: song, include: { album: { only: [ :id, :title, :cover_url ] } }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Song not found" }, status: :not_found
      end
    end
  end
end
