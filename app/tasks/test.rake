require 'rake/testtask'

Rake::TestTask.new do |t|
  ENV['FRAMEWORK_ENV'] = 'test'
  Rake::Task["environment"].invoke
  t.test_files = FileList['spec/*helper.rb']
  t.pattern = "spec/*_spec.rb"
end
