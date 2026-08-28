class ReportTask
  def initialize(report)
    @report = report
  end

  def call
    puts "Processing report #{@report.id} for customer #{@report.customer}"
    sleep(rand(1..3)) # Pretend this is an API request
    {
      report_id: @report.id,
      customer: @report.customer,
      status: :complete,
      score: rand(1..100)
    }
  end
end
