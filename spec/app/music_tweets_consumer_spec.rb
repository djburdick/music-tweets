require 'spec_helper'

describe MusicTweetsConsumer do

  it "should process records" do
    mtc = MusicTweetsConsumer.new

records = [{"data"=>"eyJjcmVhdGVkX2F0IjoiMjAxOC0wMy0xNSAxMTo1MTo0OCAtMDcwMCIsImNvb3JkaW5hdGVzIjpudWxsLCJmYXZvcml0ZWQiOmZhbHNlLCJpZF9zdHIiOiJiMDNhOWU2Ni04NmVkLTRkNTMtOWM4NS00ODMxYTRkNDM5YjYiLCJlbnRpdGllcyI6eyJoYXNodGFncyI6W10sInVzZXJfbWVudGlvbnMiOltdfSwidGV4dCI6IkVkZ2Us4oCdIERlYWQgQ29uZmVkZXJhdGUgIGEgc29uZyB0aGF0IGJvdGggcG9rZWQgZnVuIGF0IGFuZCBwYWlkIHRyaWJ1dGUgdG8gbXVzaWMgc25vYmJlcnksIHRoYXQgaW1hZ2luZWQgYSBtaXJhY2xlIG1hbiB3aG8gd2l0bmVzc2VkIGV2ZXJ5IOKAnHMiLCJtZXRhZGF0YSI6eyJpc29fbGFuZ3VhZ2VfY29kZSI6ImVuIiwicmVzdWx0X3R5cGUiOiJyZWNlbnQifSwicmV0d2VldF9jb3VudCI6MH0=", "partitionKey"=>"b03a9e66-86ed-4d53-9c85-4831a4d439b6", "approximateArrivalTimestamp"=>1521139908404, "subSequenceNumber"=>0, "action"=>"record"}]

    mtc.process_records(records, 'blah')
  end

end
