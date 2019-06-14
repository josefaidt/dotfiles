from ranger.api.commands import Command

class code(Command):
  """
  :code

  Opens current directory in VSCode
  """

  def execute(self):
    dirname = self.fm.thisdir.path
    codecmd = ["code", dirname]
    self.fm.execute_command(codecmd)