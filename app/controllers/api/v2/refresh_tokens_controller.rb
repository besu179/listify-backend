module Api
  module V2
    class RefreshTokensController < ApplicationController
      def create
        refresh_token = RefreshToken.find_by(token: params[:refresh_token])

        if refresh_token&.active?
          user = refresh_token.user

          # Rotate token: revoke old one, create new one
          refresh_token.revoke!
          new_refresh_token = user.refresh_tokens.create!

          # Generate new JWT (stateless, so we just rely on Devise-JWT to add it to headers or sign it)
          # For a custom refresh endpoint, we might need to manually sign a JWT or use Warden
          token, payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)

          render json: {
            access_token: token,
            refresh_token: new_refresh_token.token,
            expires_in: payload["exp"] - payload["iat"]
          }, status: :ok
        else
          render json: { error: "Invalid or expired refresh token" }, status: :unauthorized
        end
      end
    end
  end
end
