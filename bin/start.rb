require_relative '../init'

ComponentHost.start 'file-transfer' do |host|
  host.register FileTransferDataExport::Start
end
