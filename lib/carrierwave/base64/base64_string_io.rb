module Carrierwave
  module Base64
    class Base64StringIO < StringIO
      attr_accessor :file_extension, :file_name

      REGEX           = /\Adata:image\/.+;base64,/
      ENCODE_DEFAULT  = "data:image/png;base64"

      def initialize(file_string, file_name)

        encoded_file = default_encode(file_string)
        description, encoded_bytes = encoded_file.split(',')

        raise ArgumentError unless encoded_bytes
        raise ArgumentError if encoded_bytes.eql?('(null)')

        @file_name = file_name
        @file_extension = get_file_extension description
        bytes = ::Base64.decode64 encoded_bytes

        super bytes
      end

      def original_filename
        File.basename("#{@file_name}.#{@file_extension}")
      end

      private

      def default_encode file_string
        return file_string if REGEX === file_string
        return [ENCODE_DEFAULT, file_string].join(',')
      end

      def get_file_extension(description)
        content_type = description.split(';base64').first
        mime_type = MIME::Types[content_type].first
        unless mime_type
          raise Carrierwave::Base64::UnknownMimeTypeError,
                "Unknown MIME type: #{content_type}"
        end
        mime_type.preferred_extension
      end
    end
  end
end
