class WorkerPool
  def initialize(tasks, worker_count:)
    @tasks = Queue.new
    tasks.each { |task| @tasks << task }
    @worker_count = worker_count
    @results = []
    @results_lock = Mutex.new
  end

  def run
    puts "Starting worker pool with #{@worker_count} workers..."
    threads =
      Array.new(@worker_count) do
        Thread.new do
          loop do
            task =
              begin
                @tasks.pop(true)
              rescue ThreadError
                break
              end
            next unless task
            result = task.call
            @results_lock.synchronize { @results << result }
          end
        end
      end
    threads.each(&:join)
    @results
  end
end
