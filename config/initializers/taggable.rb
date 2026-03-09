module TagPrompt
  def self.text
    tags = ActsAsTaggableOn::Tag.pluck(:name).join(", ")
    "Izberi 1-7 oznake iz tega seznama: #{tags}. Uporabi SAMO oznake iz tega seznama. Ce je vsebina kratka je povsem OK, ce dodas samo en ali noben tag."
  end
end
