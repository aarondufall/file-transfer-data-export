module FileTransferDataExport
  module Start
    def self.call
      Consumers::Event.start "fileTransfer"
    end
  end
end
