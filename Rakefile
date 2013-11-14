PROJECT_NAME = "PebCiti"
SCHEME_NAME = "PebCiti"
APP_NAME = "PebCiti"
CONFIGURATION = "Release"
EXECUTABLE_NAME = "PebCiti"

SDK_VERSION = "7.0"
PROJECT_ROOT = File.dirname(__FILE__)
BUILD_DIR = File.join(PROJECT_ROOT, "build")
TRACKER_ID = "928128"

TESTFLIGHT_API_TOKEN = ENV["TESTFLIGHT_API_TOKEN"]
TESTFLIGHT_TEAM_TOKEN = ENV["TESTFLIGHT_TEAM_TOKEN"]
TESTFLIGHT_DISTRIBUTION_LIST = "Developers"

def build_configuration
  CONFIGURATION
end

def system_or_exit(cmd, stdout = nil)
  puts "Executing #{cmd}"
  cmd += " >#{stdout}" if stdout
  system(cmd) or raise "******** Build failed ********"
end

def output_file(target)
  output_dir = if ENV['IS_CI_BOX']
    ENV['CC_BUILD_ARTIFACTS']
  else
    Dir.mkdir(BUILD_DIR) unless File.exists?(BUILD_DIR)
    BUILD_DIR
  end

  output_file = File.join(output_dir, "#{target}.output")
  puts "Output: #{output_file}"
  output_file
end

task :default => [ :trim_whitespace ]

desc "Trim whitespace"
task :trim_whitespace do
  system_or_exit %Q[git status --porcelain | awk '{if ($1 != "D" && $1 != "R") print $NF}' | grep -e '.*\.[cmh]$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;']
end

desc "Clean all targets"
task :clean do
  system_or_exit "rm -rf #{BUILD_DIR}/*", output_file("clean")
end

task :build_for_device do
  if !ENV["TESTFLIGHT_API_TOKEN"]
    raise "******** TESTFLIGHT_API_TOKEN not set ********"
  end

  if  !ENV["TESTFLIGHT_TEAM_TOKEN"]
    raise "******** TESTFLIGHT_TEAM_TOKEN not set ********"
  end

  if `git status --short`.length != 0
    raise "******** Cannot push with uncommitted changes ********"
  end

  system_or_exit("agvtool next-version -all")
  build_number = `agvtool what-version -terse`.chomp

  system_or_exit("git commit -am'Updated build number to #{build_number}'")
  system_or_exit(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -scheme #{SCHEME_NAME} -configuration #{build_configuration} -sdk iphoneos ARCHS=armv7 build SYMROOT=#{BUILD_DIR}], output_file("build_for_device"))
  system_or_exit("git push origin master")
end


task :archive => :build_for_device do
  system_or_exit(%Q[xcrun -sdk iphoneos PackageApplication #{BUILD_DIR}/#{build_configuration}-iphoneos/#{EXECUTABLE_NAME}.app -o #{BUILD_DIR}/#{build_configuration}-iphoneos/#{EXECUTABLE_NAME}.ipa])
end

task :archive_dsym_file do
    system_or_exit(%Q[zip -r #{BUILD_DIR}/#{build_configuration}-iphoneos/#{EXECUTABLE_NAME}.app.dSYM.zip #{BUILD_DIR}/#{build_configuration}-iphoneos/#{EXECUTABLE_NAME}.app.dSYM], output_file("build_all"))
end

namespace :testflight do
  task :deploy => [:clean, :archive, :archive_dsym_file] do
    file      = "#{BUILD_DIR}/#{build_configuration}-iphoneos/#{EXECUTABLE_NAME}.ipa"
    notes     = "Please refer to Tracker (https://www.pivotaltracker.com/projects/#{TRACKER_ID}) for further information about this build"
    notes     = ENV['notes'] if ENV['notes']
    dysmzip   = "#{BUILD_DIR}/#{build_configuration}-iphoneos/#{EXECUTABLE_NAME}.app.dSYM.zip"

    system_or_exit(%Q[curl http://testflightapp.com/api/builds.json -F file=@#{file} -F dsym=@#{dysmzip} -F api_token=#{TESTFLIGHT_API_TOKEN} -F team_token="#{TESTFLIGHT_TEAM_TOKEN}" -F notes="#{notes}" -F notify=True -F distribution_lists="#{TESTFLIGHT_DISTRIBUTION_LIST}"])
  end
end
