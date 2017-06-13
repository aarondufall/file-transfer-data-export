module FileTransferDataExport
  module Consumers
    class Event
      include Consumer::Postgres

      handler Handlers::Events
    end
  end
end
