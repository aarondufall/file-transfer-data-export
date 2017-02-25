module FileTransferDataExport
  module ReadModel
    module Postgres
      class Write

        def self.configure(receiver)
          receiver.write = new
        end

        def call(entity, expected_version:)
          puts "WRITING TO READ MODEL"
          require 'pry'; binding.pry
          file = files.where(file_id: entity.file_id).first
          if file
            if file[:version] < expected_version
              files.update(entity.to_h)
            end
            return
          end
          files.insert(entity.to_h)
        end

        #TODO do something else
        def files
          @files ||= db[:files]
        end

        #TODO extract db connection
        def db
          @db ||= Sequel.postgres('file_transfer', host:'localhost', user: 'event_source')
        end
      end
    end
  end
end
