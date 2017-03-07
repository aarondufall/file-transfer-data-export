require_relative '../init'

class Master

  def initialize
    @worker_pids = []

    # The Master shares this pipe with each of its worker processes. It
    # passes the writable end down to each spawned worker while it listens
    # on the readable end. Each worker will write to the pipe each time
    # it accepts a new connection. If The Master doesn't get anything on
    # the pipe before `Config.timeout` elapses then it kills its workers
    # and exits.
    # @readable_pipe, @writable_pipe = IO.pipe
  end

  def start
    trap_signals
    spawn_worker
    loop do
      sleep 10
    end
  end

  def trap_signals
    # The QUIT signal triggers a graceful shutdown. The master shuts down
    # immediately and lets each worker finish the request they are currently
    # processing.
    old_quit_handler = trap(:QUIT) do
      verbose "Received QUIT"
      old_quit_handler.call
      kill_workers(:QUIT)
      exit
    end

    old_child_handler = trap(:CHLD) do
      old_child_handler.call
      dead_worker = Process.wait
      @worker_pids.delete(dead_worker)

      @worker_pids.each do |wpid|
        begin
          dead_worker = Process.waitpid(wpid, Process::WNOHANG)
          @worker_pids.delete(dead_worker)
        rescue Errno::ECHILD
        end
      end

      spawn_worker
    end
  end

  def kill_workers(sig)
    @worker_pids.each do |wpid|
      Process.kill(sig, wpid)
    end
  end

  def spawn_worker

    @worker_pids <<  fork do
      puts "File Transfer Event Handler Started"
      event_handler = FileTransferDataExport::Handlers::Events.build
      loop do
        EventSource::Postgres::Read.("fileTransfer") do |event_data|
          event_handler.(event_data)
        end
        sleep 0.2
      end
    end
  end

end

@master_pid = fork do
  master = Master.new
  master.start
end

[:INT, :QUIT].each do |sig|
  old_handler = trap(sig) {
    begin
      old_handler.call
      Process.kill(sig, @master_pid) if @master_pid
    rescue Errno::ESRCH
    end
    exit
  }
end

Process.waitpid(@master_pid)

