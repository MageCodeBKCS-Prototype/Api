# frozen_string_literal: true

class ProgrammingLanguage
  attr_reader :name, :extension

  def initialize(name, extension)
    @name = name
    @extension = extension
  end
end
