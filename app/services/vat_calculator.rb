class VatCalculator
  def self.rate_for(slug)
    case slug.to_sym
    when :print
      0.09
    when :digital
      0.23
    else
      raise "No vate rate for: #{ slug.to_s }"
    end
  end

  def self.net_from_gross(gross, rate)
    if rate && rate.is_a?(Symbol)
      rate = rate_for(rate)
    end

    (gross / (1 + rate))
  end

  def self.vat_from_gross(gross, rate)
    net = net_from_gross(gross, rate)
    (gross - net)
  end
end
