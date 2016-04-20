module Api
  module V1
    class Api::V1::PhotosController < ApplicationController

      def upload
        ip = request.remote_ip
        @picture = Picture.new(filename: params["file"], user_agent: request.env["HTTP_USER_AGENT"], user_ip: ip)
        if @picture.save
          pictures = Picture.where.not(user_ip: ip, id: @picture.id).order(:count)

          if pictures.any?
            pictures = get_least_shown(pictures)
            picture = pictures.sample
            picture.update_attributes(count: picture.count + 1)
          else
            picture = @picture
          end

          return success_response(picture[:filename])
        else
          return error_response("Can't upload")
        end
      end

      private
        def get_least_shown(pictures)
          c = pictures.first.count
          pics = []
          pictures.each do |p|
            pics << p if p.count == c
          end
          pics
        end

        def success_response(picture)
          render json: {
            picture: "https://s3.eu-central-1.amazonaws.com/recip-photo/uploads/#{picture}"
          }, status: 200
        end

        def error_response(content)
          render json: {
            message: content
          }, status: 500
        end
    end
  end
end


