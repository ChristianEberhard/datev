# encoding: UTF-8
require 'spec_helper'

describe Datev::Export do
  let(:booking1) {
    Datev::Booking.new(
      'Belegdatum'                     => Date.new(2016,6,21),
      'Buchungstext'                   => 'Fachbuch: Controlling für Dummies',
      'Umsatz (ohne Soll/Haben-Kz)'    => 24.95,
      'Soll/Haben-Kennzeichen'         => 'H',
      'Konto'                          => 1200,
      'Gegenkonto (ohne BU-Schlüssel)' => 4940,
      'BU-Schlüssel'                   => '8'
    )
  }

  let(:booking2) {
    Datev::Booking.new(
      'Belegdatum'                     => Date.new(2016,6,22),
      'Buchungstext'                   => 'Honorar FiBu-Seminar',
      'Umsatz (ohne Soll/Haben-Kz)'    => 5950.00,
      'Soll/Haben-Kennzeichen'         => 'S',
      'Konto'                          => 10000,
      'Gegenkonto (ohne BU-Schlüssel)' => 8400,
      'Belegfeld 1'                    => 'RE201606-135'
    )
  }

  let(:export) do
    export = Datev::Export.new(
      'Herkunft'        => 'XY',
      'Exportiert von'  => 'Chief Accounting Officer',
      'Berater'         => 123,
      'Mandant'         => 456,
      'WJ-Beginn'       => Date.new(2016,1,1),
      'Datum vom'       => Date.new(2016,6,1),
      'Datum bis'       => Date.new(2016,6,30),
      'Bezeichnung'     => 'Beispiel-Buchungen'
    )

    export << booking1
    export << booking2
    export
  end

  describe :to_s do
    subject { export.to_s }

    it 'should export as string' do
      expect(subject).to be_a(String)
      expect(subject.lines.length).to eq(4)
    end

    it "should encode in Windows-1252" do
      expect(subject.encoding).to eq(Encoding::WINDOWS_1252)
    end

    it "should contain header" do
      expect(subject.lines[0]).to include('EXTF;510')
    end

    it "should contain field names" do
      expect(subject.lines[1]).to include('Umsatz (ohne Soll/Haben-Kz);Soll/Haben-Kennzeichen')
    end

    it "should contain bookings" do
      expect(subject.lines[2]).to include('4940')
      expect(subject.lines[2].encode(Encoding::UTF_8)).to include('Controlling für Dummies')

      expect(subject.lines[3]).to include('8400')
      expect(subject.lines[3].encode(Encoding::UTF_8)).to include('Honorar FiBu-Seminar')
    end
  end

  describe :to_file do
    it 'should export a valid CSV file' do
      Dir.mktmpdir do |dir|
        filename = "#{dir}/EXTF_Buchungsstapel.csv"
        export.to_file(filename)

        expect {
          CSV.read(filename, Datev::Export::CSV_OPTIONS)
        }.to_not raise_error
      end
    end
  end
end
