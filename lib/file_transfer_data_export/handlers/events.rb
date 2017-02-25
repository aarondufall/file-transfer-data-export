module FileTransferDataExport
  module Handlers
    class Events
      include Messaging::Handle
      include Messaging::Postgres::StreamName
      include FileTransfer::Client::Messages::Events
      include Log::Dependency

      dependency :store, FileTransferDataExport::Store
      dependency :write, FileTransferDataExport::ReadModel::Postgres::Write

      def configure
        FileTransferDataExport::Store.configure self
        FileTransferDataExport::ReadModel::Postgres::Write.configure self
      end

      category :file_transfer

      handle CopiedToS3 do |copied_to_s3|
        file_id = copied_to_s3.file_id

        file, stream_version = store.get(file_id, include: :version)
        pp file.file_id
        write.(file, expected_version: stream_version)
      end

    end
  end
end
