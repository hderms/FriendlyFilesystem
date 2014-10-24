module FileHelper
  def self.safe_delete_file(file)
    if File.exists?(file)
      File.delete(file)
    end

  end
  def self.safe_append_file(file_name, contents)
    File.open(file_name, "a") do |file|
      file.write(contents)
    end
  end
end

class FriendlyTransaction
  def initialize(interactive = true,&blk)
    @commands = []
    #if interactive is true it will ask for confirmation after each step
    @interactive = interactive
    begin
      instance_eval(&blk)
    rescue StandardError => e
      puts "Rolling back transaction. Reason: #{e}"
      @commands.reverse.each(&:undo)
    end
  end
  def execute(command)
    if ask_for_permission? command
      command.execute
      @commands << command
    else
      raise "Refused permission"
    end
  end
  def ask_for_permission?(command)
    if @interactive
      puts "should I #{command.to_s}? (y/n)"
      wait_for_answer
    else
      true
    end
  end
  def wait_for_answer
    while
      input = get_input
      return input if input
    end
  end
  def get_input
    case gets.chomp.downcase
    when /^y/
      return true
    when /^n/
      return false
    else
      puts "incorrect input, must be y/n"
      return nil
    end
  end
end
class Command
  def initialize(name)
    @name = name
  end
  def to_s
    return "#{self.class} on #{@file}"
  end
  def execute
    puts "Executing #{name} on #{@arguments}."
  end
  def undo
    puts "undoing #{self.class}"

  end
end
module Undo

  module DeleteFile
    def undo
      super
      FileHelper.safe_delete_file(@file)
    end
  end
  module WriteFile
    def undo
      super
      File.open(@file, "w") do |file|
        file.write(@saved_contents)
      end
    end
  end
end
class ChangeFileCommand < Command
  include Undo::WriteFile
  def initialize(file)
    @contents = ""
    @file = file
  end
  def save_contents(contents)
    @saved_contents = contents
  end
  def execute
    File.open(@file, "r") do |file|
      save_contents(file.read())
    end
  end
end
class DeleteFileCommand < ChangeFileCommand
  def execute
    super
    #check for file existence first because it should only fail if there was an error deleting, not if we try to delete something that doesn't exist.
    FileHelper.safe_delete_file(@file)

  end
end
class CreateFileCommand < Command
  include Undo::DeleteFile
  def initialize(file, contents)
    @file = file
    @contents = contents
  end
  def execute
    File.open(@file, "w") do |file|
      file.write(@contents)
    end
  end
end
class AlwaysFail < Command
  def execute
    raise "We always fail."
  end
  def initialize
  end
end
class AppendFileCommand < ChangeFileCommand

  def initialize(filename, contents)
    super(filename)
    @contents = contents
  end
  def execute
    super
    FileHelper::safe_append_file(@file, @contents)
  end
end
