NAMES = %w[
    alex ben max leo tom sam ray eli jay gus ike kai lou ned rex sid
    ted vic wes zac ana ava bea cia dee eva fay gia hal ida joy kim
    lia may noa ora pia rae sky tia una val zoe ash blu cal dan eli
    fin gus hal ian jed ken liv mel nat oli pam qui rob sol ty ugo
    vin wyn zed bo cy dru fox gil hal ian jax kip lux moe neo oz poe
    quin roy syd taj uma van wil xan yul ziv
].freeze

class UserNameGenerator
  def self.call
    NAMES.sample
  end
end