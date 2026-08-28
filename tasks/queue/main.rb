require_relative "report"
require_relative "report_task"
require_relative "worker_pool"

reports = []
reports << Report.new(id: 1, customer: "Ada")
reports << Report.new(id: 2, customer: "Grace")
reports << Report.new(id: 3, customer: "Linus")

report_tasks = reports.map { |report| ReportTask.new(report) }

pool = WorkerPool.new(report_tasks, worker_count: 2)
results = pool.run
puts results
