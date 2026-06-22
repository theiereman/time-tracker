class Calendar::Day
  attr_reader :date

  def initialize(date, completed)
    @date = date
    @completed = completed
  end

  def completed? = @completed
end
