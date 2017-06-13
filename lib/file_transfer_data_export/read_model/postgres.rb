module FileTransferDataExport
  module ReadModel
    module Postgres
      class Write

        def self.configure(receiver)
          receiver.write = new
        end

        def call(entity, expected_version:)
          data = entity.to_h
          data.merge!(version: expected_version)

          file = files.where(file_id: entity.file_id).first
          if file
            if file[:version] < expected_version
              files.update(data)
            end
            return
          end

          files.insert(data)
        end

        #TODO do something else
        def files
          @files ||= db[:files]
        end

        #TODO extract db connection
        def db
          @db ||= Sequel.postgres('file_transfer', host:'localhost', user: 'message_store')
        end
      end
    end
  end
end
