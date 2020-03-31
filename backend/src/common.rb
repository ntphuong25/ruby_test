module Common
  def rental_period(start_date, end_date)
    converted_date(end_date) - converted_date(start_date) + 1
  end

  def converted_date(date_str)
    Date.parse(date_str).mjd
  end
end