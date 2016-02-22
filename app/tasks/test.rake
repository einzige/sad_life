require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['spec/*helper.rb']
  t.pattern = "spec/**/*_spec.rb"
end
