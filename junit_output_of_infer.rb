#!/usr/bin/env ruby

require 'nokogiri'

module InferParser
  class Issue
    attr_accessor :file, :filename, :line, :sort, :type, :details
  end
  
  class Parser
    @@regex_filepath_and_linenumber = /((\/[\.0-9a-zA-Z_-]+)+):(\d+)/
    @@regex_cause = /([a-z]+):\s*+([a-zA-Z_]+)/
    
    class << self
      def parse
        issues = []
        ARGF.each_line do |line|
          @@regex_filepath_and_linenumber.match(line)
          if !$~.nil?
            issue = Issue.new()
            issue.file = $~[1]
            issue.line = $~[3]
            issue.filename = File.basename(issue.file)
            @@regex_cause.match(line)
            issue.sort = $~[1]
            issue.type = $~[2]
            issues.push(issue)
            next
          end
          if !issues.empty? && !issues.last.file.nil? && issues.last.details.nil?
            issues.last.details = line.strip
          end
        end
        return issues
      end
    end
  end
  
  class Reporter
    class << self
      def format(issues)
        if !issues.empty?
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.testsuite(:name => 'Infer', :tests => issues.size, :failures => issues.size) {
              issues.each do |issue|
                xml.testcase(:name => "#{issue.filename}:#{issue.line}") {
                  xml.failure(:type => issue.type, :message => issue.details)
                }
              end
            }
          end
        else
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.testsuite(:name => 'Infer', :tests => '1', :errors => 0, :skipped => 0, :failures => 0)
          end
        end
        builder.to_xml
      end
      
      def generate(issues, result_file)
        File.open(result_file, 'w') do |f|
          f.puts(format(issues))
        end
      end
    end
    
    private_class_method :format
  end
end
