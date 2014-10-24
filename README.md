#FriendlyFileSystem
This is a very simple set of commands to modify the filesystem in a transactional manner. This isn't threadsafe and is subject to race conditions on multi-user operating systems.
##Example
The following example demonstrates:
* Creating a file "foo" with contents "bar"
* Deleting a file "foo"
* Creating a different file "baz" with contents "heh"
* Appending "bar" to the file "baz"
* Appending "baz" to the file "foo"
* Executing a command that always fails (thereby triggering the transaction to rollback)
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
