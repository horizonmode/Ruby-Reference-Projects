class Report
  attr_reader :id, :customer

  def initialize(id:, customer:)
    @id = id
    @customer = customer
  end
end
