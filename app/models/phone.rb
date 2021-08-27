class Phone

  attr_accessor :number
  attr_accessor :display

  def initialize(phone_number)
    @number = Phonelib.parse(phone_number)

    if self.number.country_code == "1"
      @display = self.number.full_national # (415) 555-2671;123
    else
      @display = self.number.full_international # +44 20 7183 8750
    end
  end

end