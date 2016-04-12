module Api
  module V1
    class Api::V1::PhotosController < ApplicationController

      def upload
        binding.pry
        return error_response("Wrong file type") unless params[:picture].content_type == "image/jpeg"

        @picture = Picture.new(filename: params[:picture])
        if @picture.save
          return success_response
        else
          return error_response("Can't upload")
        end
      end

      private
        def success_response
          picture = Picture.limit(1).order("RANDOM()")
          render json: {
            picture: "http://localhost:3000/uploads/pictures/#{picture.first[:filename]}"
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

