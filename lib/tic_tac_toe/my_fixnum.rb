require_relative './shared/game_parms'

module TicTacToe

  module MyFixnum
    extend self

    def _calc
      machine_bytes = ['foo'].pack('p').size
      8 * machine_bytes # == machine_bits
    end

    SIGNED_MAX = 2 ** (_calc - 2) - 1 # SIGNED_MAX(Fixnum), SIGNED_MAX + 1(Bignum)
    SIGNED_MIN = -SIGNED_MAX - 1

    # UNSIGNED_MAX = 2 ** (_calc - 1) - 1   # => Bignum
    # UNSIGNED_MIN = -UNSIGNED_MAX - 1      # => Bignum

    def const_missing(const_name)
      if const_name =~ /^MAX$|^MIN$/
        STDOUT.print("WARNING did you mean SIGNED_#{const_name}?\n")
        self.const_get "SIGNED_#{const_name}"
      else
        raise NameError, "uninitialized constant #{self}::#{const_name}"
      end
    end
  end

end
