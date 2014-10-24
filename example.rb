require_relative 'friendly_filesystem.rb'
FriendlyTransaction.new  do
  execute CreateFileCommand.new("foo", "bar")
  execute DeleteFileCommand.new("foo")
  execute CreateFileCommand.new("baz", "heh")
  execute AppendFileCommand.new("baz", "bar")
  execute AppendFileCommand.new("baz", "foo")
  execute AlwaysFail.new
end
