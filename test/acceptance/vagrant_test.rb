require File.expand_path("../base", __FILE__)

describe "vagrant and color output" do
  include_context "acceptance"

  # This is a check to see if the `expect` program is installed on this
  # computer. Some tests require this and if this doesn't exist then the
  # test itself will be skipped.
  def self.has_expect?
    `which expect`
    $?.success?
  end

  # This is a helper to check for a color in some text.
  # This will return `nil` if no color is found, any other
  # truthy value otherwise.
  def has_color?(text)
    text.index("\e[31m")
  end

  it "outputs color if there is a TTY", :if => has_expect? do
    environment.workdir.join("color.exp").open("w+") do |f|
      f.puts(<<-SCRIPT)
spawn #{environment.replace_command("vagrant")} status
expect default {}
SCRIPT
    end

    result = execute("expect", "color.exp")
    assert(has_color?(result.stdout), "output should contain color")
  end

  it "doesn't output color if there is a TTY but --no-color is present", :if => has_expect? do
    environment.workdir.join("color.exp").open("w+") do |f|
      f.puts(<<-SCRIPT)
spawn #{environment.replace_command("vagrant")} status --no-color
expect default {}
SCRIPT
    end

    result = execute("expect", "color.exp")
    assert(!has_color?(result.stdout), "output should not contain color")
  end

  it "doesn't output color in the absense of a TTY" do
    # This should always output an error, which on a TTY would
    # output color. We check that this doesn't output color.
    # If `vagrant status` itself is broken, another acceptance test
    # should catch that. We just assume it works here.
    result = execute("vagrant", "status")
    assert(!has_color?(result.stdout), "output should not contain color")
  end
end
