require_relative '../test_init'

require "rom-repository"
require "rom-sql"
require "rom/sql/extensions/postgres/commands"




module RomExample
  class File
    include Schema::DataStructure

    attribute :file_id, String
    attribute :name, String
    attribute :key, String
    attribute :bucket, String
    attribute :region, String

    module Transformer
      def self.raw_data(instance)
        instance.to_h
      end
    end
  end

  class Projection
    include EntityProjection
    include FileTransfer::Client::Messages::Events

    entity_name :file

    apply Initiated do |initiated|
      SetAttributes.(file, initiated, copy: [
        :file_id,
        :name,
      ])
    end

    apply CopiedToS3 do |copied_to_s3|
      SetAttributes.(file, copied_to_s3, copy: [
        :key,
        :bucket,
        :region
      ])
    end
  end

  class Store
    include EntityStore

    category :file_transfer
    entity File
    projection Projection
    reader MessageStore::Postgres::Read
  end

  module ROM
    class Repository < ::ROM::Repository[:files]
      commands :upsert

      def self.configure(receiver)
        repository = self.new(container)

        receiver.repository = repository
      end

      def self.container
        @container ||=
          begin
            config = ::ROM::Configuration.new(:sql, 'postgres://localhost/view_store', username: 'view_store')
            config.register_command(Upsert)

            ::ROM.container(config)
          end
      end
    end

    class Upsert < ::ROM::SQL::Commands::Postgres::Upsert
      relation :files
      register_as :upsert
      result :one

      conflict_target :file_id
      update_statement(
        :name => Sequel.qualify('excluded', 'name'),
        :key => Sequel.qualify('excluded', 'key'),
        :bucket => Sequel.qualify('excluded', 'bucket'),
        :region => Sequel.qualify('excluded', 'region'),
        :version => Sequel.qualify('excluded', 'version')
      )
    end
  end

  class Handler
    include Messaging::Handle
    include FileTransfer::Client::Messages::Events

    dependency :store, Store
    dependency :repository

    def configure
      Store.configure(self)
      ROM::Repository.configure(self)
    end

    def handle(message_data)
      file_id = message_data.data[:file_id]

      file_transfer, version = store.fetch(file_id, include: :version)

      raw_data = ::Transform::Write.raw_data(file_transfer)

      raw_data[:version] = version

      repository.upsert(raw_data)
    end
  end
end





file_id = Identifier::UUID::Random.get
event_stream = Messaging::StreamName.stream_name(file_id, 'fileTransfer')

initiated = FileTransfer::Client::Controls::Events::Initiated.example
initiated.file_id = file_id

Messaging::Postgres::Write.(initiated, event_stream)


MessageStore::Postgres::Read.(event_stream) do |message_data|
  RomExample::Handler.(message_data)
end

MessageStore::Postgres::Read.(event_stream) do |message_data|
  RomExample::Handler.(message_data)
end


copied_to_s3 = FileTransfer::Client::Controls::Events::CopiedToS3.example
copied_to_s3.file_id = file_id

Messaging::Postgres::Write.(copied_to_s3, event_stream)


MessageStore::Postgres::Read.(event_stream) do |message_data|
  RomExample::Handler.(message_data)
end

MessageStore::Postgres::Read.(event_stream) do |message_data|
  RomExample::Handler.(message_data)
end
