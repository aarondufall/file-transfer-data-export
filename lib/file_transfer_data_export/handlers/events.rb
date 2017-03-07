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
        position = copied_to_s3.metadata.position
        # TODO wrap the whole thing is a transaction
        # TODO have consumer position table
        # global_position = copied_to_s3.metadata.global_position

        file = store.get(file_id)
        #TODO position == version

        write.(file, expected_version: position)
        logger.info { "File Model Updated" }
      end

    end
  end
end
