module Datev
  class BookingExport < Export
    self.header_class = BookingHeader
    self.row_class = Booking
  end
end
