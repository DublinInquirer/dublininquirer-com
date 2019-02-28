class VatCalculator
  # in 2019, VAT rates for digital news subscription was lowered to 9%
  def self.rate_for(slug, rules = 2019)
    return 0.09 if rules.to_i >= 2019

    case slug.to_sym
    when :print
      0.09
    when :digital
      0.23
    else
      raise "No vate rate for: #{ slug.to_s }"
    end
  end

  def self.net_from_gross(gross, rate, rules = 2019)
    if rate && rate.is_a?(Symbol)
      rate = rate_for(rate, rules)
    end

    (gross / (1 + rate))
  end

  def self.vat_from_gross(gross, rate, rules = 2019)
    net = net_from_gross(gross, rate, rules)
    (gross - net)
  end
end
