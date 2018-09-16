# frozen_string_literal: true

require 'bunny'
require 'json'

class RabbitHandler
  LAST_ADDRESS = 100 # There are up to one hundred test addresses per location

  POSTCODES_CENSUS_1 = [
    'DN21 5XJ',
    'NG34 0ED',
    'PE23 4PX',
    'NG23 6GZ',
    'NG23 6JL',
    'NG23 6JR',
    'NG23 6NA',
    'NG23 6QQ',
    'NG23 6PY',
    'NG23 6PA',
    'NG23 6PQ',
    'NG23 6PN',
    'NG23 6PL',
    'DN32 9HJ',
    'DN32 9HA',
    'DN32 8DX',
    'DN35 7SG',
    'DN33 1QE',
    'DN33 1LY',
    'DN33 1LH',
    'DN33 1PE',
    'DN33 1RG',
    'LN11 0TH',
    'LN11 0TQ',
    'LN11 0UG',
    'PE8 5QH',
    'PE8 5PS',
    'PE8 5PF',
    'PE8 5PE',
    'PE8 5PJ',
    'PE8 4EX',
    'PE8 4EJ',
    'PE8 4DG',
    'PE8 4HB',
    'PE8 4HE',
    'PE8 4LF',
    'PE8 4LX',
    'PE8 4LP',
    'PE8 4NE',
    'PE8 4QH',
    'PE8 4QQ',
    'PE8 4QX',
    'PE8 4QR',
    'PE8 4PP',
    'PE8 4AZ',
    'NR21 9EN',
    'NR21 9DP',
    'NR21 8DN',
    'NR21 8JU',
    'NR21 8ER',
    'NR21 8EW',
    'NR21 8EB',
    'NR21 8PY',
    'NR21 8PE',
    'NR21 8NS',
    'NR21 8LU',
    'NR21 8EW',
  ]

  POSTCODES_CENSUS_2 = [
    'SO14 6RD',
    'SO15 2JL',
    'SO15 2JE',
    'SO15 2FQ',
    'SO15 5DH',
    'SO15 5DR',
    'SO15 2NS',
    'SO17 1DP',
    'SO17 1QX',
    'SO17 1AW',
    'SO17 3RY',
    'SO18 2JN',
    'SO18 2LT',
    'SO18 2HS',
    'SO18 2HQ',
    'SO16 3DP',
    'SO16 3QS',
    'SO16 7FS',
    'SO16 7ET',
    'SO16 8EQ',
    'SO16 8DE',
    'SO16 8FF',
    'SO16 8FG',
    'SO16 5TD',
    'SO16 5DF',
    'SO16 6BP',
    'SO16 6BH',
    'SO16 4GN',
  ]

  POSTCODES_CENSUS_3 = [
    'CT1 2AR',
    'CT1 2LS',
    'CT1 1JS',
    'CT1 1QP',
    'CT1 1QD',
    'CT1 1QA',
    'CT1 1RF',
    'CT1 1XZ',
    'CT1 3LP',
    'CT1 3UL',
    'CT1 3XW',
    'CT1 3XU',
    'CT2 8PQ',
    'CT2 8JH',
    'CT2 8EN',
    'CT2 7SY',
    'ME13 8EH',
    'ME13 7JG',
    'ME13 7SY',
    'ME13 7SQ',
    'ME13 7RD',
    'CT5 4BA',
    'CT5 4EP',
    'CT5 4DJ',
    'CT5 4HX',
    'CT5 1RS',
    'CT5 1NS',
    'CT5 2HQ',
    'CT5 2LH',
    'CT5 2NW',
    'CT5 2RY',
    'CT6 7RQ',
    'CT6 7TR',
    'CT6 7TX',
    'CT6 7LL',
    'CT3 4DW',
    'CT3 4DB',
    'CT3 1ED',
    'CT3 2HZ',
    'CT13 0NE',
    'CT13 0LY',
  ]

  POSTCODES_CENSUS_4 = [
    'PL25 3QT',
    'PL25 3SU',
    'PL25 3TS',
    'PL25 3UZ',
    'PL25 3UQ',
    'PL25 3UE',
    'PL25 4NT',
    'PL25 4RQ',
    'PL25 4SL',
    'PL25 4UU',
    'PL25 5EA',
    'TR1 1HD',
    'TR1 3TB',
    'TR1 3NU',
    'TR1 3WN',
    'TR3 6DX',
    'TR3 6DP',
    'TR4 8ER',
    'TR4 8EQ',
    'TR4 8GN',
    'TR4 8UH',
    'TR4 8DR',
    'TR4 8EE',
    'TR15 3XD',
    'TR15 3UN',
    'TR15 3UB',
    'TR14 7RW',
    'TR14 7RS',
  ]

  POSTCODES_CENSUS_5 = [
    'LL13 7BL',
    'LL13 7BB',
    'LL13 8PH',
    'LL13 8RB',
    'LL13 8US',
    'LL13 9PG',
    'LL13 9PD',
    'LL13 8YH',
    'LL13 0LX',
    'LL13 7GX',
    'CH7 4AD',
    'CH7 5ND',
    'CH7 5LN',
    'CH7 4AT',
    'CH7 4AB',
    'LL24 0HT',
    'LL24 0LB',
    'LL23 7RA',
    'LL23 7RL',
    'SY21 7NN',
    'SY21 7NB',
    'SY21 7JS',
    'SY21 7SF',
    'SY21 7DT',
    'SY21 7QP',
    'SY21 7EU',
    'SY21 7HW',
    'SY21 7HL',
    'SY21 7BG',
    'SY21 7BP',
    'SY20 8JD',
    'SY20 8HT',
    'SY20 8HU',
    'SY20 8DD',
    'SY20 8BN',
    'SY20 8BS',
    'SY20 8AF',
    'SY20 8HA',
    'SY20 8HF',
    'SY20 8EJ',
    'SA38 9JL',
    'SA38 9JL',
  ]

  def initialize(url, username, password)
    @connection = Bunny.new(hostname: url)
    @connection.start
    @channel = @connection.create_channel
    @exchange = @channel.topic('rm-jobsvc-exchange', durable: true)
    @north_addresses = JSON.parse(File.read(File.join(__dir__, '../data/addresses_north.json')))
  end

  def close()
    @connection.close
  end

  def send_one(obj)
    json = obj.to_json
    @exchange.publish(json, routing_key: 'jobsvc.job.request', persistent: true, content_type: 'text/plain')
  end

  def run(form)
    for i in 0..(form[:count].to_i - 1)
      # address = @north_addresses['addresses'][rand(1..LAST_ADDRESS)]
      postcodes = POSTCODES_CENSUS_5
      postcode = postcodes[i % postcodes.length]
      address = {postCode: postcode}
      message = {
        actionType: "Create",
        jobIdentity: SecureRandom.hex(4),
        surveyType: form[:surveyType],
        preallocatedJob: false,
        mandatoryResourceAuthNo: nil,
        dueDate: (Time.now.utc + (1*60*60)).iso8601,
        address: address,
      }
      p "Sending message: #{message}"
      send_one(message)
    end
  end
end
