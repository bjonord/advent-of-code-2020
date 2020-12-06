#!/usr/bin/env ruby

require_relative '../lib/result_output'

class Passport
  attr_reader :data

  def initialize(data)
    @data = data.gsub("\n", ' ')
  end

  def present?
    validators.map { |validator| validator[:name] }.all? { |field| data.include? field }
  end

  def valid?
    return false unless present?

    validators.all? do |validator|
      case validator[:name]
        when 'byr', 'iyr', 'eyr'
          find(data, validator)
            .then { |match| match&.[](1).to_i }
            .then { |year| validator[:range].include? year }
        when 'hgt'
          find(data, validator)
            .then do |match|
              [match&.[](1).to_i, validator[match&.[](2)&.to_sym]]
            end
            .then { |height, range| range && range.include?(height) }
      else
        find(data, validator)
      end
    end
  end

  def find(data, validator)
    regex = validator[:regex]
    data.match(regex)
  end

  def validators
    clear = "(\s|$)"
    @validators ||= [
      {
        name: 'byr',
        regex: /byr:(\d{4})#{clear}/,
        range: (1920..2002),
      },
      {
        name: 'iyr',
        regex: /iyr:(\d{4})#{clear}/,
        range: (2010..2020),
      },
      {
        name: 'eyr',
        regex: /eyr:(\d{4})#{clear}/,
        range: (2020..2030),
      },
      {
        name: 'hgt',
        regex: /hgt:(\d{2,3})(cm|in)#{clear}/,
        cm: (150..193),
        in: (59..76),
      },
      {
        name: 'hcl',
        regex: /hcl:#([0-9a-f]{6})#{clear}/
      },
      {
        name: 'ecl',
        regex: /ecl:(amb|blu|brn|gry|grn|hzl|oth)#{clear}/
      },
      {
        name: 'pid',
        regex: /pid:(\d{9})#{clear}/
      },
    ]
  end
end

class GlidingThroughThePassport
  attr_reader :input

  def initialize(input)
    @input = input
  end

  def verify(present: false)
    if present
      passports.select(&:present?).length
    else
      passports.select(&:valid?).length
    end
  end

  def passports
    @passports ||= input.split("\n\n").map { |passp| Passport.new(passp) }
  end
end

DEMO_DATA = <<-FOO
ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in
FOO

INVALID = <<-FOO
eyr:1972 cid:100
hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

iyr:2019
hcl:#602927 eyr:1967 hgt:170cm
ecl:grn pid:012533040 byr:1946

hcl:dab227 iyr:2012
ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

hgt:59cm ecl:zzz
eyr:2038 hcl:74454a iyr:2023
pid:3556412378 byr:2007
FOO

VALID = <<-FOO
pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
hcl:#623a2f

eyr:2029 ecl:blu cid:129 byr:1989
iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

hcl:#888785
hgt:164cm byr:2001 iyr:2015 cid:88
pid:545766238 ecl:hzl
eyr:2022

iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
FOO


ResultOutput.(
  info: 'Test 1 - part 1',
  result: GlidingThroughThePassport.new(DEMO_DATA).verify(present: true),
  expected: 2
)

ResultOutput.(
  info: 'Input data - part 1',
  result: GlidingThroughThePassport.new(File.read('./input.txt')).verify(present: true),
  expected: 204
)

ResultOutput.(
  info: 'Test 1 - part 2',
  result: GlidingThroughThePassport.new(INVALID).verify,
  expected: 0
)

ResultOutput.(
  info: 'Test 2 - part 2',
  result: GlidingThroughThePassport.new(VALID).verify,
  expected: 4
)

ResultOutput.(
  info: 'Input data - part 2',
  result: GlidingThroughThePassport.new(File.read('./input.txt')).verify,
  expected: 179
)
