require_relative '../test_init'

event_handler = FileTransferDataExport::Handlers::Events.build

write = Messaging::Postgres::Write.build

initiated = FileTransfer::Client::Controls::Events::Initiated.example
stream_name = event_handler.stream_name(initiated.file_id)

write.(initiated, stream_name)

copied = FileTransfer::Client::Controls::Events::CopiedToS3.example
stream_name = event_handler.stream_name(copied.file_id)

write.(copied, stream_name)

puts "reading events"

EventSource::Postgres::Read.("fileTransfer") do |event_data|
  event_handler.(event_data)
end
