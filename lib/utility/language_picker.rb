# frozen_string_literal: true
require './lib/utility/programming_language'

class LanguagePicker
  @@languages = [
    ProgrammingLanguage.new('cpp', %w[.cpp .hpp .cc .cp .cxx .c++ .h .hh .hxx .h++]),
    ProgrammingLanguage.new('python', %w[.py .py3]),
    ProgrammingLanguage.new('java', ['.java'])
  ]

  def initialize
    @by_extension = {}
    @by_name = {}

    @@languages.each { |language|
      @by_name[language.name] = language
      language.extension.each { |extension|
        @by_extension[extension] = language
      }
    }
  end

  def detect_language(filenames)
    count_language = {}
    max_count = 0
    detected_language = nil

    filenames.each { |filename|
      file_extension = File.extname(filename)
      current_count = count_language[file_extension].nil? ? 1 : count_language[file_extension]+1
      if current_count > max_count
        max_count = current_count
        detected_language = @by_extension[file_extension]
      end

      count_language[file_extension] = current_count
    }

    detected_language
  end

  def match_extension(language, extension)
    language_by_extension = @by_extension[extension]
    return false if language_by_extension.nil?

    language_by_extension.name == language.name
  end
end
