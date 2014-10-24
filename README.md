#FriendlyFileSystem
This is a very simple set of commands to modify the filesystem in a transactional manner. This isn't threadsafe and is subject to race conditions on multi-user operating systems.
```ruby
require_relative 'friendly_filesystem.rb'
FriendlyTransaction.new  do
  execute CreateFileCommand.new("foo", "bar")
  execute DeleteFileCommand.new("foo")
  execute CreateFileCommand.new("baz", "heh")
  execute AppendFileCommand.new("baz", "bar")
  execute AppendFileCommand.new("baz", "foo")
  execute AlwaysFail.new
end
```
